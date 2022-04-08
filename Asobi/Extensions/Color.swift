//
//  Color.swift
//  Asobi
//
//  Created by Brian Dashore on 10/5/21.
//

import Foundation
import SwiftUI

extension Color {
    init(rgb: String) {
        let rgbValues = rgb.dropFirst(4).dropLast(1).components(separatedBy: ", ")

        let uiColor = UIColor(
            red: CGFloat((rgbValues[0] as NSString).floatValue / 255),
            green: CGFloat((rgbValues[1] as NSString).floatValue / 255),
            blue: CGFloat((rgbValues[2] as NSString).floatValue / 255),
            alpha: 1.0
        )

        self.init(uiColor)
    }

    var isLight: Bool {
        let uiColor = UIColor(self)

        var white: CGFloat = 0
        uiColor.getWhite(&white, alpha: nil)
        return white >= 0.5
    }
}

// From zane-carter: https://gist.github.com/zane-carter/fc2bf8f5f5ac45196b4c9b01d54aca80
extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }

        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor ?? .red
            self = Color(color)
        } catch {
            self = .red
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}
