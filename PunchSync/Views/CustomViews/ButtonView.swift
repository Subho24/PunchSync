//
//  ButtonView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI

struct ButtonView: View {
    
    var buttontext: String
    
    var body: some View {
        
        Text(buttontext)
            .foregroundStyle(Color.white)
            .padding(.vertical, 12)
            .frame(minWidth: 190.0)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FE7E65"), // Start color
                        Color(hex: "E58D35"), // Middle color
                        Color(hex: "FD9709")  // End color
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(radius: 5)
            .cornerRadius(12)
            .padding(.bottom, 12)
    }
}

#Preview {
    ButtonView(buttontext: "Button")
}
