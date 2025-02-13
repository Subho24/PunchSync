//
//  DashboardTabView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct DashboardTabView: View {
    
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
    @Binding var isLocked: Bool
    @State var showAdminForm: Bool = false
    @State private var unusedPassword: String = ""
 
    var body: some View {
        // Profile Section
        VStack(spacing: 20) {
            if isLocked {
                LockedView(parentAdminPassword: $unusedPassword, showAdminForm: $showAdminForm)
                    .onChange(of: showAdminForm) {
                        withAnimation {
                            isLocked = false
                        }
                    }
            } else {
                HStack(spacing: 30) {
                    // Profile Icon
                    ProfileImage()
                    VStack(alignment: .leading, spacing: 5) {
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
              
                VStack() {
                    Text("Shift Details")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "ECE9D4"))
                        .foregroundColor(Color("PrimaryTextColor"))
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
                .padding(.vertical)
                
        
                VStack(alignment: .leading, spacing: 10) {
                    Text("Stay Informed")
                        .font(.title2)
                        .bold()
                    
                    Text("Stay informed with the latest updates and essential information tailored to your needs.")
                        .font(.body)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
          
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
                .padding(.vertical, 10)
            }
        }
        .padding()
        .onAppear {
            if let currentAdminId = Auth.auth().currentUser?.uid {
                getCompanyCode(currentAdminId) { companyCode in
                    if let code = companyCode {
                        currCompanyCode = code
                    }
                }

            } else {
                print("No admin is currently logged in")
                return
            }
        }
        Spacer()
            .frame(height: 100)
    }
}

#Preview {
    DashboardTabView(isLocked: .constant(false))
}
