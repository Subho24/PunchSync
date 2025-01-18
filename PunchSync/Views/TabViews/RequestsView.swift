//
//  RequestsView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

import SwiftUI

struct RequestsView: View {
    
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
    
    var body: some View {
        
        VStack {
            HStack(spacing: 50) {
                Circle()
                    .fill(Color(hex: "ECE9D4"))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 5)
                    .padding(.bottom, 5)
                
                VStack {
                    Text("Admin: \(adminData.fullName)")
                        .font(.headline)
                    Text("Company Code: \(adminData.companyCode)")
                }
                .task {
                    punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                        if success {
                            print("Admin data loaded successfully")
                        } else if let error = error {
                            print("Error loading admin data: \(error.localizedDescription)")
                        }
                    }
                }
            }
        
            HStack {
                Text("Leave Request")
                    .font(.title3)
                Spacer()
            }
            .padding()
            
            List {
                
            }
        }
        .padding(.bottom, 30)
    }
}

#Preview {
    RequestsView()
}
