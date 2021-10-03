//
//  WebViewModel.swift
//  Cubari
//
//  Created by Brian Dashore on 8/3/21.
//

import Foundation
import WebKit
import Combine
import SwiftUI

class WebViewModel: ObservableObject {
    let webView: WKWebView
    
    // All Settings go here
    @AppStorage("blockAds") var blockAds = false
    @AppStorage("defaultUrl") var defaultUrl = ""

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
        
        if blockAds {
            enableBlocker()
        } else {
            loadUrl()
        }
        
        setupBindings()
    }
    
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var showNavigation: Bool = true
    
    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)
        
        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)
    }
    
    // Once swift concurrency is backported, migrate this to a different class/extension
    func enableBlocker() {
        let blocklistPath = Bundle.main.path(forResource: "blocklist", ofType: "json")

        if blocklistPath == nil {
            debugPrint("Failed to find blocklist path. Continuing...")
            return
        }
        
        do {
            let blocklist = try String(contentsOfFile: blocklistPath!, encoding: String.Encoding.utf8)
            
            WKContentRuleListStore.default().compileContentRuleList(
                forIdentifier: "ContentBlockingRules", encodedContentRuleList: blocklist)
            { (contentRuleList, error) in
                if let error = error {
                    debugPrint("Blocklist loading failed: \(error.localizedDescription)")
                    return
                }
                
                self.webView.configuration.userContentController.add(contentRuleList!)
                
                self.loadUrl()
            }
        } catch {
            loadUrl()

            debugPrint("Blocklist loading failed. Loading the URL anyway")
        }
    }
    
    func disableBlocker() {
        debugPrint("Disabling adblock")
        
        webView.configuration.userContentController.removeAllContentRuleLists()
        
        self.webView.reload()
    }
    
    // Force the home URL if the user wants to go home
    // Otherwise, use the current URL with the home URL as a fallback
    func loadUrl(goHome: Bool = false) {
        let url = goHome ? buildHomeUrl() : webView.url ?? buildHomeUrl()

        let urlRequest = URLRequest(url: url)

        self.webView.load(urlRequest)
    }
    
    // Builds homepage URL from settings
    func buildHomeUrl() -> URL {
        if defaultUrl == "" {
            return URL(string: "https://cubari.moe")!
        } else if defaultUrl.hasPrefix("https://") || defaultUrl.hasPrefix("http://") {
            return URL(string: defaultUrl)!
        } else {
            return URL(string: "https://\(defaultUrl)")!
        }
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goHome() {
        loadUrl(goHome: true)
    }
}
