//
//  HostingViewController.swift
//  Asobi
//
//  Created by Brian Dashore on 4/7/22.
//

import UIKit

// Inspired by Thomas Rademaker's UIHosting controller
// Article: https://barstool.engineering/set-the-ios-status-bar-style-in-swiftui-using-a-custom-view-modifier/

// ObservableObject to observe statusbar changes and set accordingly
class HostingViewController: UIViewController, ObservableObject {
    var rootViewController: UIViewController?
    var style: UIStatusBarStyle = .lightContent {
        didSet {
            rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }

    var isHidden: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    var ignoreDarkMode: Bool = false

    init(rootViewController: UIViewController?, style: UIStatusBarStyle, ignoreDarkMode: Bool = false) {
        self.rootViewController = rootViewController
        self.style = style
        self.ignoreDarkMode = ignoreDarkMode
        super.init(nibName: nil, bundle: nil)
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
        isHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        .fade
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsStatusBarAppearanceUpdate()
    }
}
