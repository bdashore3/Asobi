//
//  UIDevice.swift
//  Asobi
//
//  Created by Brian Dashore on 10/9/21.
//

import UIKit

enum DeviceType {
    case phone
    case pad
    case mac
}

extension UIDevice {
    var deviceType: DeviceType? {
        #if targetEnvironment(macCatalyst)
        return .mac
        #else
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .phone
        case .pad:
            return .pad
        default:
            return nil
        }
        #endif
    }

    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.currentUIWindow?.safeAreaInsets.bottom ?? 0 > 0
        } else {
            return false
        }
    }
}
