//
//  MoreTabView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI

struct MoreTabView: View {
    var body: some View {
        // Profile Section
        VStack(){
            
            HStack(spacing: 50) {
                Circle()
                    .fill(Color(hex: "ECE9D4"))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 5)
                    .padding(.bottom, 5)
                
                VStack{
                    Text("Name Lastname")
                        .font(.title3)
                        .foregroundColor(.black)
                    Text("Position")
                        .foregroundColor(.gray)
                }
            }
 //
        }
    }
}

#Preview {
    MoreTabView()
}
