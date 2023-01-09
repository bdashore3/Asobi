//
//  WebView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var downloadManager: DownloadManager
    @EnvironmentObject var rootViewController: AsobiRootViewController

    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("persistNavigation") var persistNavigation = false

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, WKScriptMessageHandler {
        let parent: WebView
        init(_ parent: WebView) {
            self.parent = parent
        }

        // JS Handler for blob downloader
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "blobListener":
                guard let jsonString = message.body as? String else {
                    parent.webModel.toastDescription = "Invalid blob JSON."
                    return
                }

                parent.downloadManager.blobDownloadWith(jsonString: jsonString)
            case "findListener":
                guard let jsonString = message.body as? String else {
                    parent.webModel.toastDescription = "Invalid find in page JSON."
                    return
                }

                parent.webModel.handleFindInPageResult(jsonString: jsonString)
            default:
                debugPrint("Unknown JS message: \(message.body)")
            }
        }

        // Handle popups from methods like window.open
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            parent.webModel.handlePopup(navigationAction)
            return nil
        }

        // Will check if the user manually zoomed in
        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            if UIDevice.current.deviceType != .mac {
                parent.webModel.userDidZoom = true
            }
        }

        // Handle orientation changes here
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            if UIDevice.current.deviceType != .mac {
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
        }

        // Check if the user is zoomed in, used for resetting the zoom level on orientation change
        // Also set the previous zoom level for possible orientation change issues
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            if UIDevice.current.deviceType != .mac {
                parent.webModel.userDidZoom = false

                parent.webModel.previousZoomScale = scale
                parent.webModel.isZoomedOut = scale.roundToPlaces(2) <= scrollView.minimumZoomScale.roundToPlaces(2)
            }
        }

        // Navigation delegate methods for ProgressView/errors
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.webModel.showLoadingProgress = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.webModel.showLoadingProgress = false

            parent.webModel.setStatusbarColor()

            if !UserDefaults.standard.bool(forKey: "incognitoMode") {
                parent.webModel.addToHistory()
            }

            // One-shot boolean which makes the webview opaque again
            if parent.webModel.firstLoad {
                parent.webModel.firstLoad = false
                parent.webModel.webView.isOpaque = true
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
                parent.downloadManager.downloadTypeAlert = .http
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
                case "https":
                    if navigationAction.targetFrame == nil {
                        parent.webModel.handlePopup(navigationAction)
                    }

                    decisionHandler(.allow)
                case "http":
                    if UserDefaults.standard.bool(forKey: "httpsOnlyMode") {
                        parent.webModel.toastType = .info
                        parent.webModel.toastDescription = "Https only mode is enabled! Aborting navigation according to your preferences."

                        decisionHandler(.cancel)
                    } else {
                        if navigationAction.targetFrame == nil {
                            parent.webModel.handlePopup(navigationAction)
                        }

                        decisionHandler(.allow)
                    }
                case "blob":
                    // Defer to JS handling
                    parent.downloadManager.executeBlobDownloadJS(url: url)

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

            parent.webModel.toastDescription = error.localizedDescription
        }

        // Function for any provisional navigation errors
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            let error = error as NSError

            parent.webModel.showLoadingProgress = false

            // Error handling switch, more errors will be added if they're unnecessary
            switch error.code {
            // Error -1022 has a special message because we don't allow insecure webpage loads
            case -1022:
                parent.webModel.toastDescription = "Failed to load because this page is insecure! \nPlease contact the website dev to fix app transport security protocols!"
            // Error 102 can be ignored since that's used for downloading files
            // Error 999 can be ignored since that's an error for loading a cached webpage
            case 102, -999:
                return
            default:
                parent.webModel.toastDescription = error.localizedDescription
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo) async {
            let alert = UIAlertController(
                title: nil,
                message: message,
                preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: "OK", style: .default)

            alert.addAction(okAction)

            parent.rootViewController.present(alert, animated: true, completion: nil)
        }

        func webView(_ webView: WKWebView,
                     runJavaScriptConfirmPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (Bool) -> Void)
        {
            let alert = UIAlertController(
                title: nil,
                message: message,
                preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            }

            alert.addAction(okAction)

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            }

            alert.addAction(cancelAction)

            // Display the NSAlert
            parent.rootViewController.present(alert, animated: true, completion: nil)
        }

        func webView(_ webView: WKWebView,
                     runJavaScriptTextInputPanelWithPrompt prompt: String,
                     defaultText: String?,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping (String?) -> Void)
        {
            let alert = UIAlertController(
                title: nil,
                message: prompt,
                preferredStyle: .alert
            )

            alert.addTextField { textField in
                textField.text = defaultText
            }

            let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
                completionHandler(alert.textFields?.first?.text)
            }

            alert.addAction(submitAction)

            parent.rootViewController.present(alert, animated: true, completion: nil)
        }

        func webView(_ webView: WKWebView,
                     didReceive challenge: URLAuthenticationChallenge,
                     completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
        {
            guard let hostname = webView.url?.host else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            let authenticationMethod = challenge.protectionSpace.authenticationMethod
            switch authenticationMethod {
            case NSURLAuthenticationMethodDefault, NSURLAuthenticationMethodHTTPBasic, NSURLAuthenticationMethodHTTPDigest:
                let alert = UIAlertController(
                    title: "Authentication Required",
                    message: "\(hostname) is asking for your credentials",
                    preferredStyle: .alert
                )

                alert.addTextField { textField in
                    textField.placeholder = "Username"
                }

                alert.addTextField { textField in
                    textField.placeholder = "Password"
                    textField.isSecureTextEntry = true
                }

                let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
                    guard let username = alert.textFields?.first?.text else {
                        return
                    }

                    guard let password = alert.textFields?.last?.text else {
                        return
                    }

                    let credentials = URLCredential(user: username, password: password, persistence: .forSession)
                    completionHandler(.useCredential, credentials)
                }

                alert.addAction(submitAction)

                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                    completionHandler(.cancelAuthenticationChallenge, nil)
                }

                alert.addAction(cancelAction)

                parent.rootViewController.present(alert, animated: true, completion: nil)
            case NSURLAuthenticationMethodServerTrust:
                completionHandler(.performDefaultHandling, nil)
            default:
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }

        @objc func toggleNavigation(_ gestureRecognizer: UIGestureRecognizer) {
            if !parent.persistNavigation {
                parent.navModel.toggleNavigationBar()
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
