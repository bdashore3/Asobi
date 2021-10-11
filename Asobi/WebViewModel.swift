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
    @AppStorage("changeUserAgent") var changeUserAgent = false
    
    // Make a non mutable fallback URL
    private let fallbackUrl = URL(string: "https://duckduckgo.com/")!

    init() {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        // Clears the disk and in-memory cache. Doesn't harm accounts.
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })
        
        webView = WKWebView(
            frame: .zero,
            configuration: config
        )
        webView.allowsBackForwardNavigationGestures = true

        // Clears the white background on webpage load
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = UIColor.clear
        
        setUserAgent(changeUserAgent: changeUserAgent)
        
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
    @Published var showProgress: Bool = false
    @Published var errorDescription: String? = nil
    @Published var showError: Bool = false
    
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
            return fallbackUrl
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

    func setUserAgent(changeUserAgent: Bool) {
        if changeUserAgent && UIDevice.current.userInterfaceIdiom == .phone {
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko)"
        }
        else if changeUserAgent && (UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac) {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        } else {
            webView.customUserAgent = nil
        }
    }
}
