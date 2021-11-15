//
//  WebView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var context
    
    @EnvironmentObject var webModel: WebViewModel

    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("persistNavigation") var persistNavigation = false
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let frame = navigationAction.targetFrame,
                frame.isMainFrame {
                return nil
            }
            webView.load(navigationAction.request)
            return nil
        }
        
        // Navigation delegate methods for ProgressView/errors
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.webModel.showError = false
            parent.webModel.showProgress = true
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed navigation! Error: \(error.localizedDescription)")
            
            parent.webModel.showProgress = false
            parent.webModel.errorDescription = error.localizedDescription
            parent.webModel.showError = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.webModel.showProgress = false
            
            // Finds the background color of a webpage
            parent.webModel.webView.evaluateJavaScript("window.getComputedStyle(document.body).getPropertyValue('background-color');") { (result, error) in
                if let result = result {
                    self.parent.webModel.backgroundColor = UIColor(rgb: result as! String)
                } else {
                    self.parent.webModel.backgroundColor = nil
                }
            }
            
            // Save in history
            let newHistoryEntry = HistoryEntry(context: parent.context)
            newHistoryEntry.name = parent.webModel.webView.title
            newHistoryEntry.url = parent.webModel.webView.url?.absoluteString
            
            let now = Date()
            
            newHistoryEntry.timestamp = now.timeIntervalSince1970
            newHistoryEntry.parentHistory = History(context: parent.context)
            newHistoryEntry.parentHistory?.dateString = DateFormatter.historyDateFormatter.string(from: now)
            newHistoryEntry.parentHistory?.date = now
            
            PersistenceController.shared.save()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let error = error as NSError
            
            parent.webModel.showProgress = false

            // Error -1022 can be ignored because we don't want popup ads
            if error.code != -1022 {
                parent.webModel.errorDescription = error.localizedDescription
                parent.webModel.showError = true
            }
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        @objc func toggleNavigation(_ gestureRecognizer: UIGestureRecognizer) {
            if !parent.persistNavigation {
                parent.webModel.showNavigation.toggle()
            }
        }
        
        @objc func refreshWebView(_ sender: UIRefreshControl) {            
            parent.webModel.webView.reload()
            sender.endRefreshing()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.toggleNavigation))
        tapGesture.numberOfTapsRequired = autoHideNavigation ? 1 : 3
        tapGesture.delegate = context.coordinator
        webModel.webView.addGestureRecognizer(tapGesture)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.refreshWebView), for: .valueChanged)
        webModel.webView.scrollView.addSubview(refreshControl)
        webModel.webView.scrollView.bounces = true

        webModel.webView.uiDelegate = context.coordinator
        webModel.webView.navigationDelegate = context.coordinator

        return webModel.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Tap gesture
        if let lastGestureRecognizer = uiView.gestureRecognizers?.last {
            let tapGesture: UITapGestureRecognizer = lastGestureRecognizer as! UITapGestureRecognizer

            tapGesture.numberOfTapsRequired = autoHideNavigation ? 1 : 3
            tapGesture.isEnabled = !persistNavigation
        }
    }
}
