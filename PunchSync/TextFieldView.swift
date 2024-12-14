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
    var systemName: String
    
    var body: some View {
            HStack {
                // Add the icon
                Image(systemName: systemName)
                    .foregroundColor(Color.gray) // Set icon color
                    .padding(.horizontal, 5)
                    .scaledToFit() // Maintain aspect ratio
                    .frame(width: 20, height: 20)

                // Conditionally render SecureField or TextField
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .frame(height: 38) // Set height for the field
            .padding(.horizontal) // Add horizontal padding
            .background(Color.white) // Background for the field
            .cornerRadius(20) // Rounded corners
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border
            )
            .padding(.horizontal, 45) // Outer horizontal padding
            .padding(.bottom, 10) // Spacing below the field
        }
    }

#Preview {
    @Previewable @State var previewText = "" // Define a State variable for the preview

    return TextFieldView(
        placeholder: "Placeholder",
        text: $previewText, // Pass the binding of the State variable
        isSecure: false,
        systemName: "envelope"
    )
}
