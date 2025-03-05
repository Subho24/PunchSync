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
                .font(.title2) // Përdor fontin "title2" që është mesatar në madhësi
                .fontWeight(.semibold) // Dërrmon titullin pak më shumë, por jo shumë të theksuar
                .foregroundColor(.black) // Ngjyra e tekstit
                .padding(.top, 20)
            
            VStack {
                NavigationStack {
                    TextFieldView(placeholder: "Search \(searchText)", text: $searchField, isSecure: false, systemName: "magnifyingglass")
                }
                .searchable(text: $searchText)
            }
            .padding(.top, 20)
            .task {
                await loadAllData()
            }
            
            
            ScrollView {
                            VStack {
                                if isLoading {
                                    ProgressView("Loading employees..")
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                } else {
                                    if !pendingUsers.isEmpty {
                                        PendingUsersView(pendingUsers: pendingUsers, handleVerification: handleUserVerification)
                                    }
                                    
                                    if searchResults.contains(where: { !$0.pending }) {
                                        Section(header: Text("Verified Employees")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .padding(.leading, 16)
                                        ) {
                                            List {
                                                ForEach(searchResults, id: \.id) { employee in
                                                    if !employee.pending {
                                                        NavigationLink(destination: EmployeeDetailView(employee: employee)) {
                                                            HStack {
                                                                Image(systemName: "person.crop.circle.fill")
                                                                    .foregroundColor(.white)
                                                                    .frame(width: 30, height: 30)
                                                                
                                                                Text(employee.fullName)
                                                                    .foregroundColor(Color.white)
                                                                
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
                                                        .fill(Color(hex: "8BC5A3"))
                                                )
                                                .listRowSeparator(.hidden)
                                                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                            }
                                            .scrollContentBackground(.hidden)
                                            .frame(minHeight: 200)
                                        }
                                        .padding(.horizontal, 10)
                                    }
                                }
                            }
                            .onChange(of: searchField) {
                                filterEmployees()
                            }
                            .padding(.bottom, 20)
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
