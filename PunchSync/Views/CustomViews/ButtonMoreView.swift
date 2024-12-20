//
//  ButtonMoreView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

import SwiftUI

struct ButtonMoreView: View {
    
    var title: String
    var icon: String?
    var color: String
    
    var body: some View {
            HStack {
                if let icon = icon {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 17)
                            .foregroundColor(.black)
                    }
                    .padding(.leading, 10)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: color))
            .cornerRadius(10)
            .shadow(radius: 5)
        
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        ButtonMoreView(title: "Example Button", icon: "star.fill", color: "FE7E65")
        
        }
    }
