//
//  CompanyView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//


import SwiftUI
import Firebase
import FirebaseAuth

struct CompanyView: View {
    @State private var companies: [CompanyData] = [] // List of companies
    @State private var isLoading = true // Loading state
    @State private var errorMessage: String? = nil // Error message
    @State var punchsyncfb = PunchSyncFB()
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Companies...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            loadCompanies()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                } else if companies.isEmpty {
                    Text("No companies found.")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(companies) { company in
                            HStack {
                                Text(company.name)
                                Spacer()
                                Text("Code: \(company.code)")
                                    .foregroundStyle(Color.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "ECE9D4"))
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear {
                loadCompanies()
            }
        }
    }
    
    // Function to load companies based on the company code from the logged-in user
    func loadCompanies() {
        isLoading = true
        errorMessage = nil
        
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "No user is currently logged in"
            isLoading = false
            return
        }
        
        // Load admin data to get the company code for the logged-in user
        punchsyncfb.loadAdminData(adminData: AdminData()) { success, error in
            if let error = error {
                errorMessage = error.localizedDescription
                isLoading = false
                return
            }
            
            guard success else {
                errorMessage = "Failed to load admin data"
                isLoading = false
                return
            }
            
            // Ensure that companyCode is valid
            let adminCompanyCode = punchsyncfb.companyCode
            guard !adminCompanyCode.isEmpty else {
                errorMessage = "Admin company code is not available."
                isLoading = false
                return
            }
            // Load companies using the company code
            punchsyncFB.loadCompanies(for: adminCompanyCode) { companies, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                } else {
                    self.companies = companies ?? []
                }
                isLoading = false
            }
        }
    }
}

struct CompanyData: Identifiable {
    let id: String
    let name: String
    let code: String
    let organizationNumber: String
}

#Preview {
    CompanyView()
}
