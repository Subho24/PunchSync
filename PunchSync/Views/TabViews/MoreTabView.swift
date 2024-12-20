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
            
        }
        .padding(.top, 50)
        
        VStack(spacing: 20) {
            // First Row with 2 buttons
            HStack(spacing: 3) {
                createButton(title: "Admins", icon: "person.2.fill", color: "8BC5A3")
                createButton(title: "Schedule", icon: "calendar", color: "F5C87E")
            }
            
            // Second Row
            HStack(spacing: 3) {
                createButton(title: "Check In/Out", icon: "checkmark.rectangle", color: "7A9E6F")
                createButton(title: "Company", icon: "building.2.fill", color: "F5A623")
            }
            
            // Third Row
            HStack(spacing: 3) {
                createButton(title: "Employee Status", icon: "person.crop.circle.fill.badge.checkmark", color: "A3D8C8")
                createButton(title: "Attendance", icon: "chart.bar.fill", color: "D56D89")
            }
            
            // Fourth Row
            HStack(spacing: 3) {
                createButton(title: "Leave Requests", icon: "envelope.badge", color: "D6A72F")
                createButton(title: "Reports&Analytics", icon: "doc.text.magnifyingglass", color: "F28C82")
            }
        }
        .padding(.top, 50)
        Spacer()
    }

       // Helper function to create a button
       private func createButton(title: String, icon: String, color: String) -> some View {
           Button(action: {
               print("\(title) button pressed")
           }) {
               HStack {
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
                   
                   Text(title)
                       .font(.headline)
                       .foregroundColor(.white)
                   
                   Spacer()
               }
               .frame(maxWidth: .infinity)
               .padding()
               .background(Color(hex: color))
               .cornerRadius(10)
           }
           .padding(.horizontal)
       }
   }

#Preview {
    MoreTabView()
}
