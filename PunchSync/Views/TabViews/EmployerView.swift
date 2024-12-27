//
//  EmployerView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct EmployerView: View {
    
    @State var searchField: String = ""
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
    
    var body: some View {
        
        HStack {
            Circle()
                .fill(Color.white)
                .frame(width: 80, height: 80)
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                .shadow(radius: 5)
                .padding(.bottom, 5)
            
            VStack {
                // Display admin's name
                Text("Admin: \(adminData.fullName)")
                    .font(.headline)
            }
            .padding()
            .task {
                // Load admin data when the view appears
                await punchsyncfb.loadAdminData(adminData: adminData)
            }
            
            Spacer()
        }
        .padding()
        .padding(.leading, 30)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "ECE9D4"))
        
        VStack {
            TextFieldView(placeholder: "Search employees", text: $searchField, isSecure: false, systemName: "magnifyingglass")
            Spacer()
        }
        .padding(.top, 20)
    }
}

#Preview {
    EmployerView()
}
