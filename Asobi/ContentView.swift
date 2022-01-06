//
//  ContentView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import SwiftUIX

struct ContentView: View {
    @StateObject var webModel: WebViewModel = .init()
    @StateObject var navModel: NavigationViewModel = .init()
    @StateObject var downloadManager: DownloadManager = .init()

    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("followSystemTheme") var followSystemTheme = true
    @AppStorage("useDarkTheme") var useDarkTheme = false

    var body: some View {
        ZStack {
            // Background color for orientation changes
            Color(webModel.backgroundColor ?? .clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture(count: autoHideNavigation ? 1 : 3) {
                    navModel.showNavigationBar.toggle()
                }
                .edgesIgnoringSafeArea([.bottom, .horizontal])
                .zIndex(0)

            // WebView
            WebView(downloadManager: downloadManager)
                .alert(isPresented: $downloadManager.showDownloadConfirmAlert) {
                    Alert(
                        title: Text("Download this file?"),
                        message: Text("Would you like to start this download?"),
                        primaryButton: .default(Text("Start")) {
                            guard let downloadUrl = downloadManager.downloadUrl else {
                                webModel.errorDescription = "The download URL is invalid"
                                webModel.showError = true

                                return
                            }

                            if downloadUrl.scheme == "blob" {
                                downloadManager.executeBlobDownloadJS(url: downloadUrl)
                            } else {
                                Task {
                                    await downloadManager.httpDownloadFrom(url: downloadUrl)
                                }
                            }

                            downloadManager.downloadUrl = nil
                        },
                        secondaryButton: .cancel {
                            downloadManager.downloadUrl = nil
                        }
                    )
                }
                .fileMover(isPresented: $downloadManager.showFileMover, file: downloadManager.downloadFileUrl) { _ in }
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(1)

            // ProgressView for loading
            if webModel.showLoadingProgress {
                GroupBox {
                    VStack {
                        CircularProgressBar(webModel.webView.estimatedProgress)
                            .lineWidth(6)
                            .foregroundColor(navigationAccent)
                            .frame(width: 60, height: 60)

                        Text("Loading...")
                            .font(.title2)
                    }
                }
                .zIndex(2)
            }

            // Error view, download bar, and find in page bar
            VStack {
                Spacer()

                // Error description view
                if webModel.showError {
                    VStack {
                        GroupBox {
                            Text("Error: \(webModel.errorDescription!)")
                        }
                    }
                    .transition(AnyTransition.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            webModel.showError = false
                        }
                    }
                    .padding()
                }

                // Calls the find in page view
                if webModel.showFindInPage {
                    FindInPageView()
                        .padding(UIDevice.current.deviceType != .phone ? 10 : 0)
                }

                // Download progress bar view
                if downloadManager.showDownloadProgress {
                    VStack {
                        GroupBox {
                            Text("Downloading content...")
                            HStack {
                                ProgressView(value: downloadManager.downloadProgress, total: 1.00)
                                    .progressViewStyle(LinearProgressViewStyle(tint: navigationAccent))

                                Button("Cancel") {
                                    downloadManager.currentDownload?.cancel()
                                    downloadManager.currentDownload = nil
                                    downloadManager.showDownloadProgress = false
                                }
                            }
                        }
                    }
                    .transition(AnyTransition.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3))
                    .padding()
                }

                // Fills up navigation bar height
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: navModel.isKeyboardShowing ? 0 : (navModel.showNavigationBar ? 50 : 0))
            }
            .zIndex(3)

            // Navigation Bar
            VStack {
                Spacer()

                if navModel.showNavigationBar {
                    NavigationBarView()
                        .onAppear {
                            // Marker: If auto hiding is enabled
                            if autoHideNavigation {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    navModel.showNavigationBar = false
                                }
                            }
                        }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .sheet(item: $navModel.currentSheet) { item in
                switch item {
                case .library:
                    LibraryView(currentUrl: webModel.webView.url?.absoluteString ?? "No URL found")
                case .settings:
                    SettingsView()
                case .bookmarkEditing:
                    EditBookmarkView(bookmark: .constant(nil))
                }
            }
            .zIndex(4)
        }
        .onOpenURL { url in
            let splitUrl = url.absoluteString.replacingOccurrences(of: "asobi://", with: "")
            webModel.loadUrl(splitUrl)
        }
        .onAppear {
            if downloadManager.parent == nil {
                downloadManager.parent = webModel
            }
        }
        .applyTheme(followSystemTheme ? nil : (useDarkTheme ? "dark" : "light"))
        .environmentObject(webModel)
        .environmentObject(navModel)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
#endif
