//
//  ProfileImage.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2025-01-26.
//

import SwiftUI

struct ProfileImage: View {
    var body: some View {
        // Profile Icon
        Circle()
            .fill(Color.white)
            .frame(width: 70, height: 70)
            .overlay(
                Circle()
                    .stroke(LinearGradient(gradient: Gradient(colors: [
                        Color(hex: "283B34"),
                        Color(hex: "60BDCD"),
                        Color(hex: "8BC5A3"),
                        Color(hex: "F5C87E"),
                        Color(hex: "FE7E65")
                    ]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 6)
            )
            .shadow(radius: 6)
            .padding(.bottom, 5)
            .overlay(
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            )
        
    }
}

#Preview {
    ProfileImage()
}
