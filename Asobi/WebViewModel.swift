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
    
    // Has the page loaded once?
    private var firstLoad: Bool = false

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
        }
        
        loadUrl()
        firstLoad = false
        
        setupBindings()
    }
    
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var showNavigation: Bool = true
    @Published var showProgress: Bool = false
    @Published var errorDescription: String? = nil
    @Published var showError: Bool = false
    @Published var bookmarkName: String? = nil
    @Published var bookmarkUrl: String? = nil

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
                
                // Place load here to make sure the webpage reloads after adblock is enabled
                if !self.firstLoad {
                    self.webView.reload()
                }
            }
        } catch {
            if !self.firstLoad {
                self.webView.reload()
            }

            debugPrint("Blocklist loading failed. Loading the URL anyway")
        }
    }
    
    func disableBlocker() {
        debugPrint("Disabling adblock")
        
        webView.configuration.userContentController.removeAllContentRuleLists()
        
        self.webView.reload()
    }
    
    // Loads a URL. URL built in the buildURL function
    // TODO: store loaded URLs in history
    func loadUrl(_ urlString: String? = nil) {
        let url = buildUrl(urlString)
        let urlRequest = URLRequest(url: url)

        self.webView.load(urlRequest)
    }
    
    /*
     Builds the URL from loadUrl
     If the provided string is nil, fall back to the default URL.
     Always prefix a URL with https if not present
     If the default URL is empty, return the fallback URL.
     */
    func buildUrl(_ testString: String?) -> URL {
        if testString == nil && defaultUrl.isEmpty {
            return fallbackUrl
        }
        
        var urlString = testString ?? defaultUrl
        
        if !(urlString.hasPrefix("http://") || urlString.hasPrefix("https://")) {
            urlString = "https://\(urlString)"
        }

        return URL(string: urlString)!
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goHome() {
        loadUrl()
    }

    func setUserAgent(changeUserAgent: Bool) {
        if changeUserAgent && UIDevice.current.userInterfaceIdiom == .phone {
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko)"
        }
        else if changeUserAgent && UIDevice.current.userInterfaceIdiom == .pad {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        } else {
            webView.customUserAgent = nil
        }
    }
}
