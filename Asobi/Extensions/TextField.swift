//
//  TextField.swift
//  Asobi
//
//  Created by Brian Dashore on 6/1/22.
//

import SwiftUI

extension TextField {
    func clearButtonMode(_ clearButtonMode: UITextField.ViewMode) -> some View {
        modifier(TextFieldClearMode(clearButtonMode: clearButtonMode))
    }
}
