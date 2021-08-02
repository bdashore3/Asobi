//
//  WebView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL?
    
    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        let webView = WKWebView(
            frame: .zero,
            configuration: config
        )

        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let scopedUrl = url else {
            return
        }
        let request = URLRequest(url: scopedUrl)
        uiView.load(request)
    }
}
