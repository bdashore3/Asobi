//
//  ContentView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import SwiftUIX
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var navModel: NavigationViewModel

    @StateObject var webModel: WebViewModel = .init()
    @StateObject var downloadManager: DownloadManager = .init()

    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("useDarkTheme") var useDarkTheme = false
    @AppStorage("followSystemTheme") var followSystemTheme = true
    @AppStorage("navigationAccent") var navigationAccent: Color = .red

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
            WebView()
                .alert(item: $downloadManager.downloadTypeAlert) { alert in
                    switch alert {
                    case .http:
                        return Alert(
                            title: Text("Download this file?"),
                            message: Text("Would you like to start this download?"),
                            primaryButton: .default(Text("Start")) {
                                if let downloadUrl = downloadManager.downloadUrl {
                                    Task {
                                        await downloadManager.httpDownloadFrom(url: downloadUrl)
                                    }
                                } else {
                                    webModel.toastDescription = "The download URL is invalid"
                                    webModel.showToast = true
                                }
                            },
                            secondaryButton: .cancel {
                                downloadManager.downloadUrl = nil
                            }
                        )
                    case .blob:
                        return Alert(
                            title: Text("Keep this file?"),
                            message: Text("Would you like keep this downloaded file?"),
                            primaryButton: .default(Text("Keep")) {
                                downloadManager.completeBlobDownload()
                            },
                            secondaryButton: .cancel {
                                downloadManager.deleteBlobDownload()
                            }
                        )
                    }
                }
                .fileImporter(isPresented: $downloadManager.showDefaultDirectoryPicker, allowedContentTypes: [UTType.folder]) { result in
                    switch result {
                    case let .success(path):
                        downloadManager.setDefaultDownloadDirectory(downloadPath: path)
                    case let .failure(error):
                        webModel.toastDescription = error.localizedDescription
                        webModel.showToast.toggle()
                    }

                    navModel.currentSheet = .settings
                }
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
                if webModel.showToast {
                    VStack {
                        GroupBox {
                            switch webModel.toastType {
                            case .info:
                                Text(webModel.toastDescription ?? "This shouldn't be showing up... Contact the dev!")
                            case .error:
                                Text("Error: \(webModel.toastDescription ?? "This shouldn't be showing up... Contact the dev!")")
                            }
                        }
                    }
                    .transition(AnyTransition.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3))
                    .onAppear {
                        Task {
                            try await Task.sleep(seconds: 5)

                            webModel.showToast = false
                            webModel.toastType = .error
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
                                Task {
                                    try await Task.sleep(seconds: 3)

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
        .environmentObject(downloadManager)
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
