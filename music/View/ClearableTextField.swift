//
//  ClearableTextField.swift
//  music
//
//  Created by Agni Muhammad on 24/07/24.
//

import SwiftUI

struct ClearableTextField: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: () -> Void
    
    var body: some View {
        HStack {
            TextField(placeholder, text: $text, onCommit: onCommit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
}
