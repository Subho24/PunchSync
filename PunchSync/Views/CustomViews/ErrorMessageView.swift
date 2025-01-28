//
//  ErrorMessageView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-18.
//

import SwiftUI

struct ErrorMessageView: View {
    
    var errorMessage: String
    var height: CGFloat = 50
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(errorMessage)
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 45)
                    .frame(height: height)
                    .multilineTextAlignment(.leading)
                    .opacity(errorMessage.isEmpty ? 0 : 1) // Fade out
                    .offset(x: errorMessage.isEmpty ? 20 : 0) // Slide to the right when disappearing
                    .animation(.easeInOut, value: errorMessage.isEmpty)
                Spacer()
            }
        }
    }
}

#Preview {
    ErrorMessageView(errorMessage: "Error")
}
