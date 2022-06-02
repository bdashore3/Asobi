//
//  WebViewModel.swift
//  Asobi
//
//  Created by Brian Dashore on 8/3/21.
//

import Combine
import Foundation
import SwiftUI
import WebKit

struct FindInPageResult: Codable {
    let currentIndex: Int
    let totalResultLength: Int
}

@MainActor
class WebViewModel: ObservableObject {
    let webView: WKWebView

    let internalScripts: [JSScript] = [
        JSScript(name: "ZoomUnlocker", devices: [.phone, .pad, .mac]),
        JSScript(name: "MacOSPaste", devices: [.mac]),
        JSScript(name: "FindInPage", devices: [.phone, .pad, .mac])
    ]

    enum ToastType: Identifiable {
        var id: Int {
            hashValue
        }

        case info
        case error
    }

    // All Settings go here

    // Default false settings
    @AppStorage("blockAds") private var blockAds = false
    @AppStorage("changeUserAgent") private var changeUserAgent = false
    @AppStorage("incognitoMode") private var incognitoMode = false
    @AppStorage("blockPopups") private var blockPopups = false
    @AppStorage("clearCacheAtStart") private var clearCacheAtStart = false
    @AppStorage("useDarkTheme") private var useDarkTheme = false
    @AppStorage("loadLastHistory") private var loadLastHistory = false

    // Default true settings
    @AppStorage("followSystemTheme") private var followSystemTheme = true
    @AppStorage("allowSwipeNavGestures") private var allowSwipeNavGestures = true

    // Non-boolean settings
    @AppStorage("defaultUrl") private var defaultUrl = ""
    @AppStorage("navigationAccent") private var navigationAccent: Color = .red
    @AppStorage("statusBarAccent") private var statusBarAccent: Color = .clear
    @AppStorage("statusBarStyleType") private var statusBarStyleType: StatusBarStyleType = .automatic

    private let javaScriptLoader: JavaScriptLoader = .init()

    // Make a non mutable fallback URL
    private let fallbackUrl = URL(string: "https://kingbri.dev/asobi")!

    // Has the page loaded once?
    @Published var firstLoad: Bool = false

    // URL variable for application URL schemes
    @Published var appUrl: URL?

    // History based variables
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    // Cosmetic variables
    @Published var showLoadingProgress: Bool = false
    @Published var backgroundColor: Color = .clear

    // Toast variables
    @Published var toastDescription: String? = nil {
        didSet {
            Task {
                try? await Task.sleep(seconds: 0.1)
                showToast = true

                try await Task.sleep(seconds: 5)

                showToast = false
                toastType = .error
            }
        }
    }

    @Published var showToast: Bool = false

    // Default the toast type to error since the majority of toasts are errors
    @Published var toastType: ToastType = .error

    // Zoom variables
    @Published var isZoomedOut = false
    @Published var userDidZoom = false
    @Published var previousZoomScale: CGFloat = 0

    // Find in page variables
    @Published var findInPageEnabled = true
    @Published var showFindInPage = false
    @Published var findQuery: String = ""
    @Published var currentFindResult: Int = -1
    @Published var totalFindResults: Int = -1

    init() {
        firstLoad = true

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs

        // For airplay options to be shown and interacted with
        config.allowsAirPlayForMediaPlayback = true

        // Immediately grab inline media playback preference from UserDefaults
        let forceFullScreen = UserDefaults.standard.bool(forKey: "forceFullScreen")
        config.allowsInlineMediaPlayback = !forceFullScreen

        webView = WKWebView(
            frame: .zero,
            configuration: config
        )

        let JSLoadErrors = javaScriptLoader.loadScripts(scripts: internalScripts, webView)

        if !JSLoadErrors.isEmpty {
            for error in JSLoadErrors {
                handleJSError(scriptName: error)
            }

            toastDescription = "Could not load scripts: \"\(JSLoadErrors.joined(separator: ", "))\" \nPlease try restarting the app."
        }

        if allowSwipeNavGestures {
            webView.allowsBackForwardNavigationGestures = true
        }

        // Clears the white background on webpage load
        webView.isOpaque = false

        setUserAgent(changeUserAgent: changeUserAgent)

        Task {
            if blockAds {
                await enableBlocker()
            }

            if clearCacheAtStart {
                await clearCache()
            }
        }

        if loadLastHistory {
            if let historyUrl = fetchLastHistoryEntry() {
                loadUrl(historyUrl)
            } else {
                loadUrl()
            }
        } else {
            loadUrl()
        }

        setupBindings()
    }

    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .assign(to: &$canGoBack)

        webView.publisher(for: \.canGoForward)
            .assign(to: &$canGoForward)
    }

    // Loads a URL. URL built in the buildURL function
    func loadUrl(_ urlString: String? = nil) {
        let url = buildUrl(urlString)
        let urlRequest = URLRequest(url: url)

        webView.load(urlRequest)
    }

    /*
     Builds the URL from loadUrl
     If the provided string is nil, fall back to the default URL.
     Always prefix a URL with https if not present
     If the default URL is empty, return the fallback URL.
     */
    func buildUrl(_ testString: String?) -> URL {
        if testString == nil, defaultUrl.isEmpty {
            return fallbackUrl
        }

        var urlString = testString ?? defaultUrl

        if !(urlString.contains("://")) {
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

    func enableBlocker() async {
        guard let blocklistPath = Bundle.main.path(forResource: "blocklist", ofType: "json") else {
            debugPrint("Failed to find blocklist path. Continuing...")
            return
        }

        do {
            let blocklist = try String(contentsOfFile: blocklistPath, encoding: String.Encoding.utf8)

            let contentRuleList = try await WKContentRuleListStore.default().compileContentRuleList(
                forIdentifier: "ContentBlockingRules", encodedContentRuleList: blocklist
            )

            if let ruleList = contentRuleList {
                webView.configuration.userContentController.add(ruleList)
            }
        } catch {
            debugPrint("Blocklist loading failed. \(error.localizedDescription)")
        }

        if !firstLoad {
            webView.reload()
        }
    }

    func disableBlocker() {
        debugPrint("Disabling adblock")

        webView.configuration.userContentController.removeAllContentRuleLists()

        webView.reload()
    }

    func addToHistory() {
        let backgroundContext = PersistenceController.shared.backgroundContext

        let newHistoryEntry = HistoryEntry(context: backgroundContext)
        newHistoryEntry.name = webView.title
        newHistoryEntry.url = webView.url?.absoluteString

        let now = Date()
        newHistoryEntry.timestamp = now.timeIntervalSince1970

        let dateString = DateFormatter.historyDateFormatter.string(from: now)

        let historyRequest = History.fetchRequest()
        historyRequest.predicate = NSPredicate(format: "dateString == %@", dateString)

        // Count should usually be 1, but removes duplicates if they are present
        if var histories = try? backgroundContext.fetch(historyRequest) {
            for (i, history) in histories.enumerated() {
                let existingEntries = history.entryArray.filter { $0.url == newHistoryEntry.url && $0.name == newHistoryEntry.name }

                if !existingEntries.isEmpty {
                    for entry in existingEntries {
                        PersistenceController.shared.delete(entry, context: backgroundContext)
                    }
                }

                if history.entryArray.isEmpty {
                    PersistenceController.shared.delete(history, context: backgroundContext)
                    histories.remove(at: i)
                }
            }

            newHistoryEntry.parentHistory = histories.first ?? History(context: backgroundContext)
        } else {
            newHistoryEntry.parentHistory = History(context: backgroundContext)
        }

        newHistoryEntry.parentHistory?.dateString = dateString
        newHistoryEntry.parentHistory?.date = now

        PersistenceController.shared.save(backgroundContext)
    }

    func fetchLastHistoryEntry() -> String? {
        let viewContext = PersistenceController.shared.backgroundContext
        let request = HistoryEntry.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \HistoryEntry.timestamp, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1

        do {
            let lastHistoryObject = try viewContext.fetch(request).first

            if lastHistoryObject?.parentHistory == nil {
                toastDescription = "This history entry is a zombie! You may want to repair your history in Library > Actions"
            }

            return lastHistoryObject?.url
        } catch {
            toastDescription = "Failed to fetch your last history entry. Loading the default URL."
        }

        return nil
    }

    // TODO: May need to add delete logic if saving fails, but probably unlikely.
    func repairZombieHistory() {
        debugPrint("User requested to begin history repair")

        let backgroundContext = PersistenceController.shared.backgroundContext
        let request = HistoryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HistoryEntry.timestamp, ascending: true)]
        request.predicate = NSPredicate(format: "parentHistory == nil")

        var currentDateString = ""
        var storedParentHistory: History?

        if let zombieEntries = try? backgroundContext.fetch(request) {
            let parentHistoryRequest = History.fetchRequest()
            parentHistoryRequest.fetchLimit = 1

            for entry in zombieEntries {
                let date = Date(timeIntervalSince1970: entry.timestamp)
                let dateString = DateFormatter.historyDateFormatter.string(from: date)

                debugPrint("Working on entry with URL: \(entry.url ?? "nil") and timestamp: \(entry.timestamp)")

                if let parentHistory = storedParentHistory, dateString == currentDateString {
                    debugPrint("Assigning entry to existing parent history")

                    entry.parentHistory = parentHistory
                } else {
                    parentHistoryRequest.predicate = NSPredicate(format: "dateString == %@", dateString)

                    if let parentHistory = try? backgroundContext.fetch(parentHistoryRequest).first {
                        debugPrint("Assigning entry to existing parent history")
                        entry.parentHistory = parentHistory
                        storedParentHistory = parentHistory
                        currentDateString = dateString
                    } else {
                        debugPrint("Assigning entry to a new parent history")
                        let newParentHistory = History(context: backgroundContext)
                        newParentHistory.dateString = dateString
                        newParentHistory.date = date

                        entry.parentHistory = newParentHistory
                    }
                }
            }

            PersistenceController.shared.save(backgroundContext)
            debugPrint("history repair complete")
        }
    }

    func handlePopup(_ navigationAction: WKNavigationAction) {
        if blockPopups {
            toastType = .info

            guard let url = webView.url else {
                toastDescription = "The URL could not be found, so the popup was blocked based on your preferences"

                return
            }

            let backgroundContext = PersistenceController.shared.backgroundContext
            let popupRequest = AllowedPopup.fetchRequest()

            guard let allowedPopups = try? backgroundContext.fetch(popupRequest) else {
                toastDescription = "There was an internal error, so the popup was blocked based on your preferences"

                return
            }

            if allowedPopups.contains(where: { $0.url != nil && url.absoluteString.contains($0.url!) }) {
                webView.load(navigationAction.request)
            } else {
                toastDescription = "Popup blocked based on your preferences"
            }
        } else {
            webView.load(navigationAction.request)
        }
    }

    // Finds the background color of a webpage
    func setStatusbarColor() {
        webView.evaluateJavaScript("window.getComputedStyle(document.body).getPropertyValue('background-color');") { result, _ in
            var tempBackgroundColor: Color = .clear

            if let result = result, self.statusBarStyleType == .automatic {
                tempBackgroundColor = Color(rgb: result as! String)
            }

            // Automatic is already handled in tandem with the result
            switch self.statusBarStyleType {
            case .automatic:
                break
            case .accent:
                tempBackgroundColor = self.navigationAccent
            case .theme:
                if self.useDarkTheme {
                    tempBackgroundColor = .black
                } else if self.followSystemTheme {
                    if UITraitCollection.current.userInterfaceStyle == .dark {
                        tempBackgroundColor = .black
                    } else {
                        tempBackgroundColor = .white
                    }
                } else {
                    tempBackgroundColor = .white
                }
            default:
                tempBackgroundColor = self.statusBarAccent
            }

            withAnimation(.easeInOut(duration: 0.3)) {
                self.backgroundColor = tempBackgroundColor
            }
        }
    }

    // Handles the model part of a JS loading error
    func handleJSError(scriptName: String) {
        switch scriptName {
        case "FindInPage":
            findInPageEnabled = false
        default:
            break
        }
    }

    func handleFindInPageResult(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            toastDescription = "Cannot convert find in page JSON into data!"

            return
        }

        let decoder = JSONDecoder()

        do {
            let result = try decoder.decode(FindInPageResult.self, from: jsonData)
            currentFindResult = result.currentIndex + 1
            totalFindResults = result.totalResultLength
        } catch {
            toastDescription = error.localizedDescription
        }
    }

    func executeFindInPage() {
        if findQuery.isEmpty, totalFindResults > 0 {
            resetFindInPage()
        }

        if !findQuery.isEmpty {
            webView.evaluateJavaScript("undoFindHighlights()")
            webView.evaluateJavaScript("findAndHighlightQuery(\"\(findQuery)\")")
            webView.evaluateJavaScript("scrollToFindResult(0)")
        }
    }

    func moveFindInPageResult(isIncrementing: Bool) {
        if totalFindResults <= 0 {
            return
        }

        if isIncrementing {
            currentFindResult += 1
        } else {
            currentFindResult -= 1
        }

        if currentFindResult > totalFindResults {
            currentFindResult = 1
        } else if currentFindResult < 1 {
            currentFindResult = totalFindResults
        }

        webView.evaluateJavaScript("scrollToFindResult(\(currentFindResult - 1))")
    }

    func resetFindInPage() {
        currentFindResult = -1
        totalFindResults = -1
        findQuery = ""
        webView.evaluateJavaScript("undoFindHighlights()")
    }

    func clearCookies() async {
        debugPrint("User requested to clear cookies")

        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        let dataRecords = await WKWebsiteDataStore.default().dataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())

        await WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: dataRecords)
    }

    func clearCache() async {
        debugPrint("User requested to begin history cache")

        await WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0))
    }
}
