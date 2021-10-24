//
//  WebView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let webView: WKWebView
    
    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("persistNavigation") var persistNavigation = false
    @Binding var errorDescription: String?
    @Binding var showError: Bool
    @Binding var showNavigation: Bool
    @Binding var showProgress: Bool
    
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
            parent.showError = false
            parent.showProgress = true
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("Failed navigation! Error: \(error.localizedDescription)")
            
            parent.showProgress = false
            parent.errorDescription = error.localizedDescription
            parent.showError = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.showProgress = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let error = error as NSError
            
            parent.showProgress = false

            // Error -1022 can be ignored because we don't want popup ads
            if error.code != -1022 {
                parent.errorDescription = error.localizedDescription
                parent.showError = true
            }
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        @objc func toggleNavigation(_ gestureRecognizer: UIGestureRecognizer) {
            if !parent.persistNavigation {
                parent.showNavigation.toggle()
            }
        }
        
        @objc func refreshWebView(_ sender: UIRefreshControl) {            
            parent.webView.reload()
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
        webView.addGestureRecognizer(tapGesture)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.refreshWebView), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true

        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator

        return webView
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
