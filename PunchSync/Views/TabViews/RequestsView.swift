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
    @State private var leaveRequests: [LeaveRequest] = []
    
    var body: some View {
    
        VStack {
            HStack(spacing: 20) {
                ProfileImage()
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
                    await loadAllData()
                }
            }
        
            HStack {
                Text("Leave Requests")
                           .font(.largeTitle)
                           .fontWeight(.bold)
                           .foregroundColor(.black)
                           .padding(.top, 20)
                           .padding(.bottom, 10)
                Spacer()
            }
            .padding()
            
            List {
                // Create a section for each leave type
                Group {
                    let annualLeaves = leaveRequests.filter { $0.requestType == "Annual leave" }
                    if !annualLeaves.isEmpty {
                        Section(header: Text("Annual leave").foregroundStyle(.white)) {
                            ForEach(annualLeaves, id: \.id) { leave in
                                HStack {
                                    Text(leave.employeeName)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    let sickLeaves = leaveRequests.filter { $0.requestType == "Sick leave" }
                    if !sickLeaves.isEmpty {
                        Section(header: Text("Sick leave").foregroundStyle(.white)) {
                            ForEach(sickLeaves, id: \.id) { leave in
                                HStack {
                                    Text(leave.employeeName)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    let parentalLeaves = leaveRequests.filter { $0.requestType == "Parental leave" }
                    if !parentalLeaves.isEmpty {
                        Section(header: Text("Parental leave").foregroundStyle(.white)) {
                            ForEach(parentalLeaves, id: \.id) { leave in
                                HStack {
                                    Text(leave.employeeName)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    let unpaidLeaves = leaveRequests.filter { $0.requestType == "Unpaid leave" }
                    if !unpaidLeaves.isEmpty {
                        Section(header: Text("Unpaid leave").foregroundStyle(.white)) {
                            ForEach(unpaidLeaves, id: \.id) { leave in
                                HStack {
                                    Text(leave.employeeName)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    let studyLeaves = leaveRequests.filter { $0.requestType == "Study leave" }
                    if !studyLeaves.isEmpty {
                        Section(header: Text("Study leave").foregroundStyle(.white)) {
                            ForEach(studyLeaves, id: \.id) { leave in
                                HStack {
                                    Text(leave.employeeName)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    let careLeaves = leaveRequests.filter { $0.requestType == "Care leave" }
                    if !careLeaves.isEmpty {
                        Section(header: Text("Care leave").foregroundStyle(.white)) {
                            ForEach(careLeaves, id: \.id) { leave in
                                HStack {
                                    Text(leave.employeeName)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    let specialLeaves = leaveRequests.filter { $0.requestType == "Special leave" }
                    if !specialLeaves.isEmpty {
                        Section(header: Text("Special leave").foregroundStyle(.white)) {
                            ForEach(specialLeaves, id: \.id) { leave in
                                HStack {
                                    Text(leave.employeeName)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    let leaveWithoutPay = leaveRequests.filter { $0.requestType == "Leave without pay" }
                    if !leaveWithoutPay.isEmpty {
                        Section(header: Text("Leave without pay").foregroundStyle(.white)) {
                            ForEach(leaveWithoutPay, id: \.id) { leave in
                                HStack {
                                    Text(leave.employeeName)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "8BC5A3"))
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            }
            .scrollContentBackground(.hidden)
        }
        .padding(.bottom, 30)
    }
    
    private func loadAllData() async {
       await withCheckedContinuation { continuation in
           punchsyncfb.loadAdminData(adminData: adminData) { success, error in
               if success {
                   // När adminData är laddat, ladda leaveRequests
                   let companyCode = adminData.companyCode
                   punchsyncfb.loadLeaveRequests(forCompanyCode: companyCode) { leaveRequests, error in
                       if let error = error {
                           print("Failed to load leave requests: \(error)")
                       } else if let loadedRequests = leaveRequests {
                           DispatchQueue.main.async {
                               self.leaveRequests = loadedRequests
                           }
                       }
                   }
               } else if let error = error {
                   print("Failed to load admin data: \(error.localizedDescription)")
               }
               continuation.resume()
           }
       }
   }
}

#Preview {
    RequestsView()
}
