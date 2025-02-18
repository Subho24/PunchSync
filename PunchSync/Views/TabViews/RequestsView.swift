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
    @State private var selectedCategory: String = ""
    @State private var categories: [String] = ["Annual leave", "Sick leave", "Parental leave", "Unpaid leave", "Study leave", "Care leave", "Special leave", "Leave without pay"]
    
    @State private var pendingLeaveRequests: [String: Any] = [:]
    @State private var isLoading = true

    
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
                    // First load admin data
                    punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                        if success {
                            print("Admin data loaded successfully")
                            // Only load pending leave requests after admin data is loaded
                            Task {
                                await loadPendingLeaveRequests()
                            }
                        } else if let error = error {
                            print("Error loading admin data: \(error)")
                        }
                    }
                    await loadAllData()
                }
            }
            
            Section(header: Text("Pending Leave Requests")) {
                ForEach(Array(pendingLeaveRequests.keys), id: \.self) { requestId in
                    if let leaveRequestData = pendingLeaveRequests[requestId] as? [String: Any],
                       let employeeName = leaveRequestData["employeeName"] as? String,
                       let title = leaveRequestData["title"] as? String,
                       let userId = leaveRequestData["userId"] as? String {
                        VStack(alignment: .leading) {
                            Text("Employee: \(employeeName)")
                                .font(.headline)
                            Text("Title: \(title)")
                                .padding(.bottom, 10)
                            
                            HStack {
                                Button("Verify") {
                                    // Here you'd call your verifyLeaveRequest function
                                   
                                }
                                .padding(8)
                                .padding(.horizontal, 15)
                                .background(Color.green)
                                .cornerRadius(10)
                                .foregroundStyle(.white)
                                
                                Button("Deny") {
                                    // Here you'd call your verifyLeaveRequest function with approved=false
                                    
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
        
            HStack {
                Text("Leave Requests")
                   .font(.largeTitle)
                   .fontWeight(.bold)
                   .foregroundColor(Color("SecondaryTextColor"))
                   .padding(.top, 20)
                   .padding(.bottom, 10)
                Spacer()
            }
            .padding()
            
            Menu {
                ForEach(categories, id: \.self) { category in
                    Button(category) {
                        selectedCategory = category
                    }
                }
            } label: {
                HStack {
                    Text(selectedCategory.isEmpty ? "Choose Leave Request Type" : selectedCategory)
                        .foregroundColor(Color.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "FE7E65"))
                )
            }
            .padding(.horizontal)

            // Display leave requests based on selected category
            if !selectedCategory.isEmpty {
                let filteredRequests = leaveRequests.filter { $0.requestType == selectedCategory }
                
                if filteredRequests.isEmpty {
                    Text("No leave requests found in this category.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(filteredRequests, id: \.id) { leave in
                            HStack {
                                Text(leave.employeeName)
                                Spacer()
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
            }
        }
        .padding(.bottom, 30)
        
        Spacer()
    }
    
    private func loadPendingLeaveRequests() async {
        // Validate companyCode first to prevent crash
        guard !adminData.companyCode.isEmpty else {
            print("Warning: Company code is empty, cannot load pending leave requests")
            return
        }
        
        await withCheckedContinuation { continuation in
            punchsyncfb.getPendingLeaveRequests(companyCode: adminData.companyCode) { leaveRequests, error in
                if let error = error {
                    print("Error loading pending leave requests: \(error)")
                }
                
                if let pendingLeaveRequests = leaveRequests {
                    DispatchQueue.main.async {
                        self.pendingLeaveRequests = pendingLeaveRequests
                        self.isLoading = false
                    }
                }
                continuation.resume()
            }
        }
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
