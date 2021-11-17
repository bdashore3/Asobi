//
//  Color.swift
//  Asobi
//
//  Created by Brian Dashore on 10/5/21.
//

import Foundation
import SwiftUI

// From zane-carter: https://gist.github.com/zane-carter/fc2bf8f5f5ac45196b4c9b01d54aca80
extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else{
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
