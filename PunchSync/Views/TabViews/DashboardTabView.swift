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
    @State var activeEmployees : [String] = []
    @State var currCompanyCode : String = ""
    
    func getCompanyCode(_ userId: String, completion: @escaping (String?) -> Void) {
        let ref = Database.database().reference()

        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any],
               let companyCode = value["companyCode"] as? String {
                completion(companyCode)
            } else {
                completion(nil) // Return nil if companyCode is not found
            }
        }
    }
    
    func getUsersByCompanyCode(companyCode: String, completion: @escaping ([String: [String: Bool]]) -> Void) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let users = snapshot.value as? [String: [String: Any]] else {
                print("No users found.")
                completion([:])  // Return an empty dictionary if no users found
                return
            }
            
            var result: [String: [String: Bool]] = [:]
            
            for (_, userData) in users {
                if let userCompanyCode = userData["companyCode"] as? String,
                   let fullName = userData["fullName"] as? String,
                   userCompanyCode == companyCode {
                    
                    // Determine active status (Assuming `pending` means inactive)
                    let isActive = !(userData["pending"] as? Bool ?? false)
                    
                    // Add to result dictionary
                    result[fullName] = ["active": isActive]
                }
            }
            
            completion(result)  // Return the processed dictionary
        }
    }


    
 
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
                        .foregroundColor(.black)
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
    DashboardTabView(isLocked: .constant(true))
}
