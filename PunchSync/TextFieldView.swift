//
//  TextFieldView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI

struct TextFieldView: View {
    
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .frame(height: 38)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                    )
                    .padding([.horizontal], 45)
                    .padding(.bottom, 10)
            } else {
                TextField(placeholder, text: $text)
                    .frame(height: 38)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                    )
                    .padding([.horizontal], 45)
                    .padding(.bottom, 10)
            }
        }
    }
}

#Preview {
    @Previewable @State var previewText = "" // Define a State variable for the preview

    return TextFieldView(
        placeholder: "Placeholder",
        text: $previewText, // Pass the binding of the State variable
        isSecure: false
    )
}
