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
    @Binding var showNavigation: Bool
    @AppStorage("persistNavigation") var persistNavigation = false
    
    class Coordinator: NSObject, WKNavigationDelegate, UIGestureRecognizerDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
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
        tapGesture.numberOfTapsRequired = 3
        tapGesture.delegate = context.coordinator
        webView.addGestureRecognizer(tapGesture)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.refreshWebView), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Tap gesture
        let tapGesture = uiView.gestureRecognizers?.last
        
        tapGesture!.isEnabled = !persistNavigation
    }
}
