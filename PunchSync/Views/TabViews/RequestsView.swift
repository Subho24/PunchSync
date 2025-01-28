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
            HStack(spacing: 50) {
                Circle()
                    .fill(Color(hex: "ECE9D4"))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 5)
                    .padding(.bottom, 5)
                
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
                    .font(.title3)
                Spacer()
            }
            .padding()
            
            List {
                ForEach(leaveRequests, id: \.id) { LeaveRequest in
                    HStack {
                        Text("\(LeaveRequest.employeeName)")
                        Spacer()
                        Text("\(LeaveRequest.requestType)")
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
