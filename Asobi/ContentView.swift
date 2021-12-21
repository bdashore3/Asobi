//
//  ContentView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import SwiftUIX

struct ContentView: View {
    @StateObject var webModel: WebViewModel = WebViewModel()
    @StateObject var navModel: NavigationViewModel = NavigationViewModel()
    @StateObject var downloadManager: DownloadManager = DownloadManager()

    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    @AppStorage("autoHideNavigation") var autoHideNavigation = false

    var body: some View {
        ZStack {
            Color(webModel.backgroundColor ?? .clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture(count: autoHideNavigation ? 1 : 3) {
                    webModel.showNavigation.toggle()
                }
                .edgesIgnoringSafeArea([.bottom, .horizontal])
                .zIndex(0)

            // Open cubari on launch
            WebView(downloadManager: downloadManager)
                .alert(isPresented: $downloadManager.showDuplicateDownloadAlert) {
                    Alert(
                        title: Text("Download could not start"),
                        message: Text("Please cancel the existing download and try again"),
                        dismissButton: .default(Text("OK"))
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

                if webModel.showNavigation {
                    NavigationBarView()
                        .onAppear {
                            // Marker: If auto hiding is enabled
                            if autoHideNavigation {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    webModel.showNavigation = false
                                }
                            }
                        }
                }
            }
            .sheet(item: $navModel.currentSheet) { item in
                switch item {
                case .library:
                    LibraryView(currentUrl: webModel.webView.url?.absoluteString)
                case .settings:
                    SettingsView()
                case .bookmarkEditing:
                    EditBookmarkView(bookmark: .constant(nil))
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .zIndex(3)
        }
        .onAppear {
            if downloadManager.parent == nil {
                downloadManager.parent = webModel
            }
        }
        .environmentObject(webModel)
        .environmentObject(navModel)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
