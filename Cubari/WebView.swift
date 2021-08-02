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
        // Configure the WebView
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        let webView = WKWebView(
            frame: .zero,
            configuration: config
        )
        webView.allowsBackForwardNavigationGestures = true
        
        // Make a request here
        guard let scopedUrl = url else {
            return webView
        }
        let request = URLRequest(url: scopedUrl)
        
        webView.load(request)
        return webView
    }
    
    // Keep this function empty otherwise all progress on WebView is lost
    // This issue is fixed in iOS 15, but the app has a minver of iOS 14
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
