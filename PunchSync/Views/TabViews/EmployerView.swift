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
                punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                    if success {
                        print("Admin data loaded successfully")
                        
                        punchsyncfb.loadEmployees(for: adminData.companyCode) { loadedEmployees, error in
                            if let loadedEmployees = loadedEmployees {
                                DispatchQueue.main.async {
                                    self.employees = loadedEmployees
                                    self.isLoading = false
                                }
                                print("Employees loaded: \(loadedEmployees)")
                            } else if let error = error {
                                print("Error loading employees: \(error.localizedDescription)")
                            }
                        }
                    } else if let error = error {
                        print("Error loading admin data: \(error.localizedDescription)")
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .padding(.leading, 30)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "ECE9D4"))
        
        VStack {
            TextFieldView(placeholder: "Search employees", text: $searchField, isSecure: false, systemName: "magnifyingglass")
        }
        .padding(.top, 20)
        
        VStack {
            if isLoading {
                ProgressView("Loading employees..")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(employees) { employee in
                        HStack() {
                            Text(employee.fullName)
                            Spacer()
                            Text(employee.isAdmin ? "Admin" : "Employee")
                                .foregroundStyle(employee.isAdmin ? Color.red : Color.blue)
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
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    EmployerView()
}
