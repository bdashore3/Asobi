//
//  DateFormatter.swift
//  Asobi
//
//  Created by Brian Dashore on 11/14/21.
//

import Foundation

extension DateFormatter {
    static let historyDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "ddMMyyyy"
        
        return df
    }()
}
