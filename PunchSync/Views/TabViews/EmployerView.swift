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
            VStack(spacing: 0) {
              
                HStack {
                    ProfileImage()
                    
                    VStack {
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

             
                Text("My Employees")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.top, 20)

                
                VStack {
                    NavigationStack {
                        TextFieldView(placeholder: "Search \(searchText)", text: $searchField, isSecure: false, systemName: "magnifyingglass")
                            .onChange(of: searchField) { _ in
                                filterEmployees()
                            }
                    }
                    .searchable(text: $searchText)
                }
                .padding(.top, 20)

                ScrollView {
                    VStack(spacing: 10) {
                        if isLoading {
                            ProgressView("Loading employees..")
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            if !pendingUsers.isEmpty {
                                PendingUsersView(pendingUsers: pendingUsers, handleVerification: handleUserVerification)
                            }

                            if !searchResults.isEmpty {
                                VStack(alignment: .leading, spacing: 5) {
                                   
                                    Text("Verified Employees")
                                        .font(.headline) 
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 10)
                                    
                                    
                                    ForEach(searchResults.filter { !$0.pending }, id: \.id) { employee in
                                        NavigationLink(destination: EmployeeDetailView(employee: employee)) {
                                            HStack {
                                                Image(systemName: "person.crop.circle.fill")
                                                    .foregroundColor(.white)
                                                    .frame(width: 30, height: 30)

                                                Text(employee.fullName)
                                                    .foregroundColor(.white)

                                                Spacer()

                                                Text(employee.isAdmin ? "Admin" : "Employee")
                                                    .foregroundStyle(employee.isAdmin ? Color.red : Color.blue)
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color(hex: "8BC5A3"))
                                            )
                                            .cornerRadius(10)
                                        }
                                    }
                                    .onDelete(perform: handleDelete)
                                }
                                .padding(.horizontal)
                            } else {
                                Text("No employees found")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)


            }
        }
    }

    
    
    
    private func loadAdminData() async {
        // Load admin data first
        await withCheckedContinuation { continuation in
            punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                if success {
                    continuation.resume()
                }
            }
        }
    }

    private func loadEmployees() async {
        await withCheckedContinuation { continuation in
            punchsyncfb.loadEmployees(for: adminData.companyCode) { loadedEmployees, error in
                if let loadedEmployees = loadedEmployees {
                    DispatchQueue.main.async {
                        self.employees = loadedEmployees
                        self.searchResults = loadedEmployees
                    }
                }
                continuation.resume()
            }
        }
    }

    private func loadPendingUsers() async {
        await withCheckedContinuation { continuation in
            punchsyncfb.getPendingUsers(companyCode: adminData.companyCode) { users, error in
                if let pendingUsers = users {
                    DispatchQueue.main.async {
                        self.pendingUsers = pendingUsers
                        self.isLoading = false
                    }
                }
                continuation.resume()
            }
        }
    }

    private func loadAllData() async {
        await loadAdminData()
        await loadEmployees()
        await loadPendingUsers()
    }
    
    private func handleUserVerification(userId: String, approved: Bool) {
         punchsyncfb.verifyUser(userId: userId, approved: approved) { success, error in
             if success {
                 DispatchQueue.main.async {
                     pendingUsers.removeValue(forKey: userId)
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

    private func searchEmployees(by searchTerm: String) -> [EmployeeData] {
        return employees.filter { employee in
            let words = employee.fullName.split(separator: " ")
            return words.contains { word in
                word.lowercased().hasPrefix(searchTerm.lowercased())
            }
        }
    }

    private func filterEmployees() {
        searchResults = searchField.isEmpty ? employees : searchEmployees(by: searchField)
    }
    
    func handleDelete(at offsets: IndexSet) {
        offsets.forEach { index in
            let employee = searchResults[index]
            let userId = employee.id // Använd 'id' som unikt identifierare
            
            punchsyncfb.removeUser(userId: userId) { success, error in
                if success {
                    // Ta bort från lokala listan efter borttagning från databasen
                    DispatchQueue.main.async {
                        searchResults.remove(at: index)
                    }
                } else if let error = error {
                    // Hantera felmeddelandet
                    DispatchQueue.main.async {
                        self.errorMessage = error
                    }
                }
            }
        }
    }
}

#Preview {
    EmployerView()
}
