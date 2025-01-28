//
//  DashboardTabView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI
import Firebase

struct DashboardTabView: View {
    
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
    @Binding var isLocked: Bool
    @State var showAdminForm: Bool = false
 
    var body: some View {
        // Profile Section
        VStack(spacing: 20) {
            if isLocked {
                LockedView(showAdminForm: $showAdminForm)
                    .onChange(of: showAdminForm) {
                        withAnimation {
                            isLocked = false
                        }
                    }
            } else {
                HStack(spacing: 50) {
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
                    
                    VStack(alignment: .leading, spacing: 5) { // Përdor spacing më të vogël për përmbajtjen
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
                .padding(.vertical) // Shto padding për të ndarë seksionin
                
                // Shift Details Table
                VStack(spacing: 0) {
                    Text("Shift Details")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "ECE9D4"))
                        .font(.headline)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Text("Active Employees")
                            Spacer()
                            Text("8")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(hex: "ECE9D4").opacity(0.1))
                    }
                    .font(.body)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "ECE9D4"), lineWidth: 1)
                )
                .padding(.vertical) // Shto padding vertikal
                
                // Title and Text Content
                VStack(alignment: .leading, spacing: 10) {
                    Text("Stay Informed")
                        .font(.title2)
                        .bold()
                    
                    Text("Stay informed with the latest updates and essential information tailored to your needs.")
                        .font(.body)
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                .padding(.vertical, 10) // Shto pak hapësirë lart e poshtë
                
                // Dashboard Button
                Button(action: {
                    print("Add New Data")
                }) {
                    HStack {
                       
                        
                        Text("Add New Data")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "8BC5A3"))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical, 10) // Shto padding vertikal për ndarje
            }
        }
        .padding() // Shto padding rreth gjithë përmbajtjes
    }
}

#Preview {
    DashboardTabView(isLocked: .constant(true))
}
