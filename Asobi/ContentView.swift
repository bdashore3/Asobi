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
    @State private var showAppStoreAlert = false

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
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(1)

            // ProgressView for loading
            if webModel.showProgress {
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
            showAppStoreAlert.toggle()
        }
        .alert(isPresented: $showAppStoreAlert) {
            Alert(
                title: Text("Asobi is on the App Store!"),
                message: Text("Click the button to download"),
                primaryButton: .default(Text("Download")) {
                    UIApplication.shared.open(URL(string: "https://apps.apple.com/us/app/asobi/id1589812837")!)
                },
                secondaryButton: .destructive(Text("Ignore"))
            )
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
