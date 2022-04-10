//
//  SettingsBehaviorView.swift
//  Asobi
//
//  Created by Brian Dashore on 4/9/22.
//

import SwiftUI

struct SettingsBehaviorView: View {
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @AppStorage("persistNavigation") var persistNavigation = false
    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("forceFullScreen") var forceFullScreen = false
    @AppStorage("clearCacheAtStart") var clearCacheAtStart = false

    @AppStorage("allowSwipeNavGestures") var allowSwipeNavGestures = true

    @AppStorage("statusBarPinType") var statusBarPinType: StatusBarBehaviorType = .partialHide

    @State private var showForceFullScreenAlert: Bool = false

    var body: some View {
        // MARK: Browser behavior settings

        Section(header: Text("Behavior"),
                footer: Text(
                    "The clear cache option clears browser cache on app launch. \nThe allow browser swipe gestures option toggles the webview's navigation gestures."
                )) {
            Toggle(isOn: $persistNavigation) {
                Text("Lock navigation bar")
            }
            .onChange(of: persistNavigation) { changed in
                if changed {
                    autoHideNavigation = false
                }

                navModel.setNavigationBar(true)
            }

            Toggle(isOn: $autoHideNavigation) {
                Text("Auto hide navigation bar")
            }
            .onChange(of: autoHideNavigation) { changed in
                // Immediately hide the navbar to force autohide functionality
                if changed {
                    navModel.setNavigationBar(false)
                }
            }
            .disabledAppearance(persistNavigation)
            .disabled(persistNavigation)

            NavigationLink(
                destination: StatusBarBehaviorPicker(),
                label: {
                    HStack {
                        Text("Status bar behavior")
                        Spacer()
                        Group {
                            switch statusBarPinType {
                            case .hide:
                                Text("Hidden")
                            case .partialHide:
                                Text("Partially hidden")
                            case .pin:
                                Text("Pinned")
                            }
                        }
                        .foregroundColor(.gray)
                    }
                }
            )
            .onChange(of: statusBarPinType) { _ in
                webModel.setStatusbarColor()
            }

            Toggle(isOn: $forceFullScreen) {
                Text("Force fullscreen video")
            }
            .onChange(of: forceFullScreen) { _ in
                showForceFullScreenAlert.toggle()
            }
            .alert(isPresented: $showForceFullScreenAlert) {
                Alert(
                    title: Text(forceFullScreen ? "Fullscreen enabled" : "Fullscreen disabled"),
                    message: Text("Changing this setting requires an app restart"),
                    dismissButton: .cancel(Text("OK!"))
                )
            }

            Toggle(isOn: $clearCacheAtStart) {
                Text("Clear cache on app launch")
            }

            Toggle(isOn: $allowSwipeNavGestures) {
                Text("Allow browser swipe gestures")
            }
            .onChange(of: allowSwipeNavGestures) { changed in
                if changed {
                    webModel.webView.allowsBackForwardNavigationGestures = true
                } else {
                    webModel.webView.allowsBackForwardNavigationGestures = false
                }
            }
        }
    }
}

struct SettingsBehaviorView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsBehaviorView()
    }
}
