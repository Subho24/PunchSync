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
    
    @State private var selectedTab = 0

    
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
            
            Picker("Leave Requests", selection: $selectedTab) {
                Text("Pending requests").tag(0)
                Text("Verified requests").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 50)
            .padding(.horizontal, 20)
            
            switch selectedTab {
            case 0:
                ForEach(Array(pendingLeaveRequests.keys), id: \.self) { requestId in
                    if let leaveRequestData = pendingLeaveRequests[requestId] as? [String: Any],
                       let employeeName = leaveRequestData["employeeName"] as? String,
                       let title = leaveRequestData["title"] as? String,
                       let userId = leaveRequestData["userId"] as? String {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Employee: \(employeeName)")
                             .font(.headline)
                             .foregroundColor(.black)
                                                                         
                             Text("Title: \(title)")
                             .font(.subheadline)
                             .foregroundColor(.gray)
                        
                            
                            HStack(spacing: 12) {
                                Button("Verify") {
                                    verifyLeaveRequest(requestId: requestId, approved: true)
                                    
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "8BC5A3"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.green.opacity(0.5), radius: 4, x: 0, y: 2)
                                
                                Button("Deny") {
                                    verifyLeaveRequest(requestId: requestId, approved: false)
                                    
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "C96D59"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.green.opacity(0.5), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                }
                
            case 1:
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
                
                if !selectedCategory.isEmpty {
                    let filteredRequests = leaveRequests.filter {
                        
                        $0.requestType == selectedCategory && !$0.pending
                    }
                    
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
            default:
                EmptyView()
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
    
    private func verifyLeaveRequest(requestId: String, approved: Bool) {
        punchsyncfb.verifyLeaveRequest(requestId: requestId, companyCode: adminData.companyCode, approved: approved) { [self] success, error in
            if success {
                DispatchQueue.main.async {
                    // Remove from pending requests
                    self.pendingLeaveRequests.removeValue(forKey: requestId)
                    
                    // Reload all leave requests to update the list
                    Task {
                        await withCheckedContinuation { continuation in
                            punchsyncfb.loadLeaveRequests(forCompanyCode: adminData.companyCode) { leaveRequests, error in
                                if let error = error {
                                    print("Failed to reload leave requests: \(error)")
                                } else if let loadedRequests = leaveRequests {
                                    DispatchQueue.main.async {
                                        self.leaveRequests = loadedRequests
                                    }
                                }
                                continuation.resume()
                            }
                        }
                    }
                }
            } else if let error = error {
                print("Error verifying leave request: \(error)")
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
