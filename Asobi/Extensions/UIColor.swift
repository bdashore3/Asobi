//
//  UIColor.swift
//  Asobi
//
//  Created by Brian Dashore on 10/29/21.
//

import Foundation
import UIKit

extension UIColor {
    public convenience init(rgb: String) {
        let rgbValues = rgb.dropFirst(4).dropLast(1).components(separatedBy: ", ")

        self.init(
            red: CGFloat((rgbValues[0] as NSString).floatValue / 255),
            green: CGFloat((rgbValues[1] as NSString).floatValue / 255),
            blue: CGFloat((rgbValues[2] as NSString).floatValue / 255),
            alpha: 1.0
        )

        return
    }
}
