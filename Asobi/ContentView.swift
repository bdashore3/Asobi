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

    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    @AppStorage("autoHideNavigation") var autoHideNavigation = false

    @State var orientation: UIDeviceOrientation = UIDevice.current.orientation

    var body: some View {
        ZStack {
            // If the device is landscape, set the background color to the computed UIColor
            Color(orientation.isLandscape ? webModel.backgroundColor ?? .clear : .clear)
                .onTapGesture(count: autoHideNavigation ? 1 : 3) {
                    webModel.showNavigation.toggle()
                }
                .onReceive(NotificationCenter.Publisher(center: .default, name: UIDevice.orientationDidChangeNotification)) { _ in
                  self.orientation = UIDevice.current.orientation
                }
                .ignoresSafeArea()
                .zIndex(0)

            // Open cubari on launch
            WebView()
                .alert(isPresented: $webModel.showDuplicateDownloadAlert) {
                    Alert(
                        title: Text("Download could not start"),
                        message: Text("Please cancel the existing download and try again"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .fileMover(isPresented: $webModel.showFileMover, file: webModel.downloadFileUrl) { _ in }
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
                
                 if webModel.showDownloadProgress {
                    VStack {
                        GroupBox {
                            Text("Downloading content...")
                            HStack {
                                ProgressView(value: webModel.downloadProgress, total: 1.00)
                                    .progressViewStyle(LinearProgressViewStyle(tint: navigationAccent))
                                
                                Button("Cancel") {                                    
                                    webModel.currentDownload?.cancel()
                                    webModel.currentDownload = nil
                                    webModel.showDownloadProgress = false
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
