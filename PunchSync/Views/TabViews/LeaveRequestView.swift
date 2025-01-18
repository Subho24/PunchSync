//
//  LeaveRequestView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-18.
//

import SwiftUI

struct LeaveRequestView: View {
    
    @State var title = ""
    let requestTypes = ["Annual leave", "Sick leave", "Parental leave", "Unpaid leave", "Study leave", "Care leave", "Special leave", "Leave without pay"]
    @State private var selectedRequestType: String = ""
    @State var description = ""
    
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    
    @StateObject private var employeeData = EmployeeData(id: "123", data: ["fullName": ""])
    
    @State var punchsyncfb = PunchSyncFB()
    
    @State private var isLoading = false
    @State private var isSuccess = false
    @State var errorMessage = ""
    
    var body: some View {
        
        ScrollView {
            VStack {
                HStack {
                    Circle()
                        .fill(Color(hex: "ECE9D4"))
                        .frame(width: 80, height: 80)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .shadow(radius: 5)
                        .padding(.bottom, 5)
                        .padding(.trailing, 15)
                    VStack {
                        Text("\(employeeData.fullName)")
                            .font(.headline)
                        Button(action: {
                            punchsyncfb.userLogout()
                        }) {
                            Text("Sign out")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(hex: "ECE9D4"))
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                }
                .padding(.leading, 38)
                .task {
                    punchsyncfb.loadEmployeeData(employeeData:  employeeData) { success, error in
                        if success {
                            print("Employee data loaded successfully")
                        } else if let error = error {
                            print("Error loading admin data: \(error.localizedDescription)")
                        }
                    }
                }
                Text("Leave Request")
                    .font(.title)
                    .padding(.vertical, 30)
                HStack {
                    Text("Title:")
                    Spacer()
                }
                .padding(.horizontal, 50)
                
                TextFieldView(placeholder: "", text: $title, systemName: "briefcase")
                
                VStack {
                    Menu {
                        ForEach(requestTypes, id: \.self) { requestType in
                            Button(requestType) {
                                selectedRequestType = requestType
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedRequestType.isEmpty ? "Request type" : selectedRequestType)
                                .foregroundColor(selectedRequestType.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .padding(.bottom)
                    .padding(.horizontal, 45)
                }
                
                HStack {
                    Text("Description:")
                    Spacer()
                }
                .padding(.horizontal, 50)
                
                TextEditor(text: $description)
                    .frame(height: 100) 
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border
                    )
                    .padding(.horizontal, 45)
                
                VStack {
                    DatePicker("Start Date:",
                               selection: $startDate,
                               displayedComponents: [.date]
                    )
                    .padding(.vertical, 5)
                    
                    DatePicker("End Date:",
                               selection: $endDate,
                               in: startDate...,  // Ensures end date can't be before start date
                               displayedComponents: [.date]
                    )
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 30)
                
                ErrorMessageView(errorMessage: errorMessage)
                
                Button(action: {
                    punchsyncfb.saveLeaveRequest(title: title, requestType: selectedRequestType, description: description, startDate: startDate, endDate: startDate,
                        completion: { success, error in
                        if let error = error {
                            isSuccess = false
                            self.errorMessage = error
                        } else if success {
                             isSuccess = true
                             title = ""
                             selectedRequestType = ""
                             description = ""
                             startDate = Date()
                             endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
                             errorMessage = ""
                             }
                         })
                     }) {
                         ButtonView(buttontext: "Send Leave Request")
                    }
            }
        }
    }
}

#Preview {
    LeaveRequestView()
}
