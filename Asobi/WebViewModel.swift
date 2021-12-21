//
//  WebViewModel.swift
//  Asobi
//
//  Created by Brian Dashore on 8/3/21.
//

import Foundation
import WebKit
import Combine
import SwiftUI

@MainActor
class WebViewModel: ObservableObject {
    let webView: WKWebView

    // All Settings go here
    @AppStorage("blockAds") var blockAds = false
    @AppStorage("defaultUrl") var defaultUrl = ""
    @AppStorage("changeUserAgent") var changeUserAgent = false
    @AppStorage("incognitoMode") var incognitoMode = false

    // Make a non mutable fallback URL
    private let fallbackUrl = URL(string: "https://duckduckgo.com/")!

    // Has the page loaded once?
    private var firstLoad: Bool = false
    
    // History based variables
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    // Cosmetic variables
    @Published var showNavigation: Bool = true
    @Published var showLoadingProgress: Bool = false
    @Published var backgroundColor: UIColor?

    // Error variables
    @Published var errorDescription: String? = nil
    @Published var showError: Bool = false
    
    // Zoom variables
    @Published var isZoomedIn = false

    init() {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs

        // For airplay options to be shown and interacted with
        config.allowsAirPlayForMediaPlayback = true
        config.allowsInlineMediaPlayback = true

        let zoomJs = """
        let viewport = document.querySelector("meta[name=viewport]");

        // Edit the existing viewport, otherwise create a new element
        if (viewport) {
            viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, user-scalable=1');
        } else {
            let meta = document.createElement('meta');
            meta.name = 'viewport'
            meta.content = 'width=device-width, initial-scale=1.0'
            document.head.appendChild(meta)
        }
        """

        if UIDevice.current.deviceType == .phone || UIDevice.current.deviceType == .pad {
            let zoomEvent = WKUserScript(source: zoomJs, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            config.userContentController.addUserScript(zoomEvent)
        }

        webView = WKWebView(
            frame: .zero,
            configuration: config
        )
        webView.allowsBackForwardNavigationGestures = true

        // Clears the white background on webpage load
        webView.isOpaque = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        setUserAgent(changeUserAgent: changeUserAgent)

        Task {
            // Clears the disk and in-memory cache. Doesn't harm accounts.
            await WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0))

            if blockAds {
                await enableBlocker()
            }
        }

        loadUrl()
        firstLoad = false

        setupBindings()
    }

    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)

        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)
    }

    func resetZoom() {
        webView.scrollView.setZoomScale(1.0, animated: true)
    }

    func enableBlocker() async {
        guard let blocklistPath = Bundle.main.path(forResource: "blocklist", ofType: "json") else {
            debugPrint("Failed to find blocklist path. Continuing...")
            return
        }

        do {
            let blocklist = try String(contentsOfFile: blocklistPath, encoding: String.Encoding.utf8)
            
            let contentRuleList = try await WKContentRuleListStore.default().compileContentRuleList(
                forIdentifier: "ContentBlockingRules", encodedContentRuleList: blocklist)
            
            if let ruleList = contentRuleList {
                self.webView.configuration.userContentController.add(ruleList)
            }
        } catch {
            debugPrint("Blocklist loading failed. \(error.localizedDescription)")
        }

        if !self.firstLoad {
            self.webView.reload()
        }
    }

    func disableBlocker() {
        debugPrint("Disabling adblock")

        webView.configuration.userContentController.removeAllContentRuleLists()

        self.webView.reload()
    }

    // Loads a URL. URL built in the buildURL function
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

    // The user agent will be a variant of safari to enable airplay support everywhere
    func setUserAgent(changeUserAgent: Bool) {
        let mobileUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1"
        let desktopUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"

        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if changeUserAgent {
                webView.customUserAgent = desktopUserAgent
            } else {
                webView.customUserAgent = mobileUserAgent
            }
        case .pad:
            if changeUserAgent {
                webView.customUserAgent = mobileUserAgent
            } else {
                webView.customUserAgent = desktopUserAgent
            }
        default:
            webView.customUserAgent = nil
        }
    }
}
