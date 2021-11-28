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
import Alamofire

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

    init() {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs

        // For airplay options to be shown and interacted with
        config.allowsAirPlayForMediaPlayback = true
        config.allowsInlineMediaPlayback = true

        // Clears the disk and in-memory cache. Doesn't harm accounts.
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{ })

        webView = WKWebView(
            frame: .zero,
            configuration: config
        )
        webView.allowsBackForwardNavigationGestures = true

        // Clears the white background on webpage load
        webView.isOpaque = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        setUserAgent(changeUserAgent: changeUserAgent)
        
        if blockAds {
            enableBlocker()
        }
        
        loadUrl()
        firstLoad = false
        
        setupBindings()
    }

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
    
    // Download handling variables
    @Published var currentDownload: DownloadRequest? = nil
    @Published var downloadFileUrl: URL? = nil
    @Published var downloadProgress: Double = 0.0
    @Published var showDuplicateDownloadAlert: Bool = false
    @Published var showDownloadProgress: Bool = false {
        didSet {
            if self.showDownloadProgress == false && self.downloadFileUrl != nil {
                self.showFileMover = true
            }
        }
    }
    @Published var showFileMover: Bool = false {
        didSet {
            if !showFileMover && downloadFileUrl != nil {
                // Reset all download info to prepare for the next one
                downloadFileUrl = nil
                currentDownload = nil
            }
        }
    }

    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)
        
        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)
    }
    
    // Download file from page
    func downloadDocumentFrom(url downloadUrl : URL) {
        if currentDownload != nil {
            showDuplicateDownloadAlert = true
            return
        }
        
        let destination: DownloadRequest.Destination = { tempUrl, response in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let suggestedName = response.suggestedFilename ?? "unknown"
            
            let fileURL = documentsURL.appendingPathComponent(suggestedName)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        currentDownload = AF.download(downloadUrl, to: destination)
            .downloadProgress { progress in
                self.downloadProgress = progress.fractionCompleted
                self.showDownloadProgress = true

                if progress.fractionCompleted == 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showDownloadProgress = false
                    }
                }
            }
            .response { response in
                if response.error == nil, let currentPath = response.fileURL {
                    self.downloadFileUrl = currentPath
                }
            }
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
