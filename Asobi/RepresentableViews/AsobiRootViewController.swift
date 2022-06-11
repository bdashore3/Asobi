//
//  HostingViewController.swift
//  Asobi
//
//  Created by Brian Dashore on 4/7/22.
//

import SwiftUI
import UIKit

// Inspired by Thomas Rademaker's UIHosting controller
// Article: https://barstool.engineering/set-the-ios-status-bar-style-in-swiftui-using-a-custom-view-modifier/

// ObservableObject to observe statusbar changes and set accordingly
class AsobiRootViewController: UIViewController, ObservableObject {
    @AppStorage("statusBarPinType") var statusBarPinType: StatusBarBehaviorType = .partialHide

    var rootViewController: UIViewController?
    var style: UIStatusBarStyle = .lightContent {
        didSet {
            rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }

    var statusBarHidden: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    var grayHomeIndicator: Bool = false {
        didSet {
            rootViewController?.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }

    var ignoreDarkMode: Bool = false

    init(rootViewController: UIViewController?, style: UIStatusBarStyle, ignoreDarkMode: Bool = false) {
        self.rootViewController = rootViewController
        self.style = style
        self.ignoreDarkMode = ignoreDarkMode

        super.init(nibName: nil, bundle: nil)

        if statusBarPinType == .hide {
            statusBarHidden = true
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let child = rootViewController else { return }
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if ignoreDarkMode || traitCollection.userInterfaceStyle == .light {
            return style
        } else {
            if style == .darkContent {
                return .lightContent
            } else {
                return .darkContent
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        statusBarHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        if grayHomeIndicator {
            return [.bottom]
        } else {
            return []
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsStatusBarAppearanceUpdate()
    }
}
