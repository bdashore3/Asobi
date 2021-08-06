//
//  WebViewModel.swift
//  Cubari
//
//  Created by Brian Dashore on 8/3/21.
//

import Foundation
import WebKit
import Combine

class WebViewModel: ObservableObject {
    let webView: WKWebView
    
    init() {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        webView = WKWebView(
            frame: .zero,
            configuration: config
        )
        webView.allowsBackForwardNavigationGestures = true

        loadUrl()
        setupBindings()
    }
    
    @Published var urlString: String = "https://cubari.moe"
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var showNavigation: Bool = true
    
    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)
        
        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)
    }
    
    func loadUrl() {
        guard let url = URL(string: urlString) else {
            return
        }
        
        webView.load(URLRequest(url: url))
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goHome() {
        self.urlString = "https://cubari.moe"
        
        loadUrl()
    }
}
