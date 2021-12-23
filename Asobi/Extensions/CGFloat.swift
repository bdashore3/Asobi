//
//  CGFloat.swift
//  Asobi
//
//  Created by Brian Dashore on 12/23/21.
//

import Foundation
import CoreGraphics

extension CGFloat {
    func roundToPlaces(_ places: Int) -> Double {
        let multiplier = pow(10, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
