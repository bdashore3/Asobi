//
//  WebView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Environment(\.managedObjectContext) var context

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @ObservedObject var downloadManager: DownloadManager

    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("persistNavigation") var persistNavigation = false

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // JS Handler for blob downloader
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "blobListener":
                guard let jsonString = message.body as? String else {
                    parent.webModel.errorDescription = "Invalid blob JSON."
                    parent.webModel.showError = true

                    return
                }

                parent.downloadManager.blobDownloadWith(jsonString: jsonString)
            case "findListener":
                guard let jsonString = message.body as? String else {
                    parent.webModel.errorDescription = "Invalid find in page JSON."
                    parent.webModel.showError = true

                    return
                }

                parent.webModel.handleFindInPageResult(jsonString: jsonString)
            default:
                debugPrint("Unknown JS message: \(message.body)")
            }
        }

        // Will check if the user manually zoomed in
        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            parent.webModel.userDidZoom = true
        }

        // Handle orientation changes here
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            // If the user initiated the zoom, we don't care
            if parent.webModel.userDidZoom {
                return
            }

            if parent.webModel.isZoomedOut {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
            } else if scrollView.zoomScale.roundToPlaces(2) > parent.webModel.previousZoomScale.roundToPlaces(2) {
                // If the scale is zoomed in on an orientation change,
                // revert back to the previous one saved in model
                scrollView.setZoomScale(parent.webModel.previousZoomScale, animated: false)
            }
        }

        // Check if the user is zoomed in, used for resetting the zoom level on orientation change
        // Also set the previous zoom level for possible orientation change issues
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            parent.webModel.userDidZoom = false

            parent.webModel.previousZoomScale = scale
            parent.webModel.isZoomedOut = scale.roundToPlaces(2) <= scrollView.minimumZoomScale.roundToPlaces(2)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let frame = navigationAction.targetFrame,
               frame.isMainFrame
            {
                return nil
            }
            webView.load(navigationAction.request)
            return nil
        }

        // Navigation delegate methods for ProgressView/errors
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.webModel.showError = false
            parent.webModel.showLoadingProgress = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.webModel.showLoadingProgress = false

            // Finds the background color of a webpage
            parent.webModel.webView.evaluateJavaScript("window.getComputedStyle(document.body).getPropertyValue('background-color');") { result, _ in
                if let result = result {
                    self.parent.webModel.backgroundColor = UIColor(rgb: result as! String)
                } else {
                    self.parent.webModel.backgroundColor = nil
                }
            }

            if !parent.webModel.incognitoMode {
                // Save in history
                let newHistoryEntry = HistoryEntry(context: parent.context)
                newHistoryEntry.name = parent.webModel.webView.title
                newHistoryEntry.url = parent.webModel.webView.url?.absoluteString

                let now = Date()

                newHistoryEntry.timestamp = now.timeIntervalSince1970
                newHistoryEntry.parentHistory = History(context: parent.context)
                newHistoryEntry.parentHistory?.dateString = DateFormatter.historyDateFormatter.string(from: now)
                newHistoryEntry.parentHistory?.date = now

                PersistenceController.shared.save()
            }
        }

        // Check if a page can be downloaded
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationResponse: WKNavigationResponse,
                     decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void)
        {
            if navigationResponse.canShowMIMEType {
                decisionHandler(.allow)
            } else {
                parent.downloadManager.downloadUrl = navigationResponse.response.url
                parent.downloadManager.showDownloadConfirmAlert.toggle()

                decisionHandler(.cancel)
            }
        }

        // Switch based on the URL scheme. All http/https rules get allowed automatically
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
        {
            if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased() {
                switch scheme {
                case "https", "http":
                    // Any web URL
                    // parent.webModel.currentWebViewAlert = .appUrlConfirm

                    decisionHandler(.allow)
                case "blob":
                    // Defer to JS handling
                    parent.downloadManager.downloadUrl = url
                    parent.downloadManager.showDownloadConfirmAlert.toggle()

                    decisionHandler(.cancel)
                default:
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }

                    decisionHandler(.cancel)
                }
            } else {
                decisionHandler(.allow)
            }
        }
        
        // Function for navigation errors
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            let error = error as NSError

            parent.webModel.showLoadingProgress = false

            // Error 999 can be ignored since that's an error for loading a cached webpage
            if error.code == -999 {
                return
            }
            
            parent.webModel.errorDescription = error.localizedDescription
            parent.webModel.showError = true
        }

        // Function for any provisional navigation errors
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let error = error as NSError

            parent.webModel.showLoadingProgress = false

            // Error handling switch, more errors will be added if they're unnecessary
            switch error.code {
            // Error -1022 has a special message because we don't allow insecure webpage loads
            case -1022:
                parent.webModel.errorDescription = "Failed to load because this page is insecure! \nPlease contact the website dev to fix app transport security protocols!"
            // Error 102 can be ignored since that's used for downloading files
            case 102:
                return
            default:
                parent.webModel.errorDescription = error.localizedDescription
            }

            parent.webModel.showError = true
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }

        @objc func toggleNavigation(_ gestureRecognizer: UIGestureRecognizer) {
            if !parent.persistNavigation {
                parent.navModel.showNavigationBar.toggle()
            }
        }

        @objc func refreshWebView(_ sender: UIRefreshControl) {
            parent.webModel.webView.reload()
            sender.endRefreshing()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        webModel.webView.configuration.userContentController.add(context.coordinator, name: "blobListener")
        webModel.webView.configuration.userContentController.add(context.coordinator, name: "findListener")

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.toggleNavigation))
        tapGesture.numberOfTapsRequired = autoHideNavigation ? 1 : 3
        tapGesture.delegate = context.coordinator
        webModel.webView.addGestureRecognizer(tapGesture)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.refreshWebView), for: .valueChanged)
        webModel.webView.scrollView.addSubview(refreshControl)
        webModel.webView.scrollView.bounces = true

        webModel.webView.uiDelegate = context.coordinator
        webModel.webView.navigationDelegate = context.coordinator
        webModel.webView.scrollView.delegate = context.coordinator

        return webModel.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Tap gesture
        if let lastGestureRecognizer = uiView.gestureRecognizers?.last {
            guard let tapGesture: UITapGestureRecognizer = lastGestureRecognizer as? UITapGestureRecognizer else {
                return
            }

            tapGesture.numberOfTapsRequired = autoHideNavigation ? 1 : 3
            tapGesture.isEnabled = !persistNavigation
        }
    }
}
