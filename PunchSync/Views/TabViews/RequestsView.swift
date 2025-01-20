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
                    Text("\(LeaveRequest.requestType)")
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    private func loadAllData() async {
        await withCheckedContinuation { continuation in
            punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                if success {
                    punchsyncfb.loadLeaveRequests { [self] leaveRequests, error in
                        if let error = error {
                            print("Failed to load leave requests: \(error)")
                        } else if let loadedRequests = leaveRequests {
                            // Update the state variable on the main thread
                            DispatchQueue.main.async {
                                self.leaveRequests = loadedRequests
                            }
                        }
                        continuation.resume()
                    }
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

#Preview {
    RequestsView()
}
