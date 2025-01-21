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
    
    @State private var employees: [EmployeeData] = []
    @State private var isLoading = true
    
    @State var searchText = ""
    @State private var searchResults: [EmployeeData] = []
    @State private var pendingUsers: [String: Any] = [:]
    @State var approved: Bool = false
    
    @State var errorMessage = ""

    
    var body: some View {
        NavigationStack {
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
                    await loadAllData()
                }
                
                Spacer()
            }
            .padding()
            .padding(.leading, 30)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "ECE9D4"))
            
           
            VStack {
                NavigationStack {
                    TextFieldView(placeholder: "Search \(searchText)", text: $searchField, isSecure: false, systemName: "magnifyingglass")
                }
                .searchable(text: $searchText)
            }
            .padding(.top, 20)
            
            VStack {
                if isLoading {
                    ProgressView("Loading employees..")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if !pendingUsers.isEmpty {
                        Section(header: Text("Pending Users")) {
                            ForEach(Array(pendingUsers.keys), id: \.self) { personalNumber in
                                if let userData = pendingUsers[personalNumber] as? [String: Any],
                                   let fullName = userData["fullName"] as? String {
                                    VStack {
                                        Text(fullName)
                                            .padding(.bottom, 20)
                                        HStack {
                                            Button("Verify") {
                                                handleUserVerification(personalNumber: personalNumber, approved: true)
                                            }
                                            .padding(8)
                                            .padding(.horizontal, 15)
                                            .background(Color.green)
                                            .cornerRadius(10)
                                            .foregroundStyle(.white)
                                            
                                            Button("Deny") {
                                                handleUserVerification(personalNumber: personalNumber, approved: false)
                                            }
                                            .padding(8)
                                            .padding(.horizontal, 15)
                                            .background(Color.red)
                                            .cornerRadius(10)
                                            .foregroundStyle(.white)
                                        }
                                    }
                                    .padding(.horizontal, 25)
                                    .padding(.top, 20)
                                }
                            }
                        }
                    }
                    List {
                        ForEach(searchResults, id: \.id) { employee in
                            if !employee.pending {
                                NavigationLink(destination: EmployeeDetailView(employee: employee)) {
                                    HStack() {
                                        Text(employee.fullName)
                                        Spacer()
                                        Text(employee.isAdmin ? "Admin" : "Employee")
                                            .foregroundStyle(employee.isAdmin ? Color.red : Color.blue)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: handleDelete)
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
            .onChange(of: searchField) {
                filterEmployees()
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    private func loadAllData() async {
        // Load admin data first
        await withCheckedContinuation { continuation in
            punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                if success {
                    // After admin data is loaded, load employees
                    punchsyncfb.loadEmployees(for: adminData.companyCode) { loadedEmployees, error in
                        if let loadedEmployees = loadedEmployees {
                            DispatchQueue.main.async {
                                self.employees = loadedEmployees
                                self.searchResults = loadedEmployees
                            }
                            
                            // After employees are loaded, load pending users
                            punchsyncfb.getPendingUsers(companyCode: adminData.companyCode) { users, error in
                                if let pendingUsers = users {
                                    DispatchQueue.main.async {
                                        self.pendingUsers = pendingUsers
                                        self.isLoading = false
                                    }
                                }
                            }
                        }
                    }
                }
                continuation.resume()
            }
        }
    }
    
    private func handleUserVerification(personalNumber: String, approved: Bool) {
        punchsyncfb.verifyUser(personalNumber: personalNumber, companyCode: adminData.companyCode, approved: approved) { success, error in
            if success {
                DispatchQueue.main.async {
                    pendingUsers.removeValue(forKey: personalNumber)
                    if approved {
                        punchsyncfb.loadEmployees(for: adminData.companyCode) { loadedEmployees, error in
                            if let loadedEmployees = loadedEmployees {
                                self.employees = loadedEmployees
                                self.searchResults = loadedEmployees
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func filterEmployees() {
        if searchField.isEmpty {
            searchResults = employees
        } else {
            searchResults = employees.filter { employee in
                // Split the full name into words
                let words = employee.fullName.split(separator: " ")
                
                // Check if any word starts with the search text (case insensitive)
                return words.contains { word in
                    word.lowercased().hasPrefix(searchField.lowercased())
                }
            }
        }
    }
    
    func handleDelete(at offsets: IndexSet) {
        offsets.forEach { index in
            let employee = searchResults[index]
            punchsyncfb.removeUser(personalNumber: employee.personalNumber) { success, error in
                if success {
                    // Ta bort från lokala listan efter borttagning från databasen
                    searchResults.remove(at: index)
                } else if let error = error {
                    // Hantera felmeddelandet
                    self.errorMessage = error
                }
            }
        }
    }
}

#Preview {
    EmployerView()
}
