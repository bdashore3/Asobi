//
//  UIDevice.swift
//  Cubari
//
//  Created by Brian Dashore on 10/9/21.
//

import SwiftUI

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
        switch UIDevice.current.userInterfaceIdiom
        {
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
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        }
        return false
    }
}
