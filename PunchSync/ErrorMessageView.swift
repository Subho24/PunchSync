//
//  ErrorMessageView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-18.
//

import SwiftUI

struct ErrorMessageView: View {
    
    var errorMessage: String
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Text(errorMessage)
                    .foregroundStyle(Color.red)
                    .padding(.horizontal, 45)
                    .frame(height: 50)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
    }
}

#Preview {
    ErrorMessageView(errorMessage: "Error")
}
