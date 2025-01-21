//
//  EmployeeMoreTabView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-20.
//

import SwiftUI

struct EmployeeMoreTabView: View {
    
    @State var navigateToProfileView = false
    @State var navigateToLeaveRequestView = false
    @State var navigateToStatisticView = false
    
    @State var punchsyncfb = PunchSyncFB()
    @StateObject private var employeeData = EmployeeData(id: "123", data: ["fullName": ""])
 
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Profile Section
                    VStack {
                        HStack(spacing: 50) {
                            Circle()
                                .fill(Color(hex: "ECE9D4"))
                                .frame(width: 80, height: 80)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 5)
                                .padding(.bottom, 5)
                            
                            VStack {
                                Text("\(employeeData.fullName)")
                                    .font(.headline)
                            }
                            .task {
                                punchsyncfb.loadEmployeeData(employeeData:  employeeData) { success, error in
                                    if success {
                                        print("Employee data loaded successfully")
                                    } else if let error = error {
                                        print("Error loading admin data: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 50)
                    
                    VStack(spacing: 38) {
                        
                        Button(action: {
                            navigateToProfileView = true
                        }) {
                            ButtonMoreView(title: "Profile", icon: "person.fill", color: "283B34")
                        }
                        .navigationDestination(isPresented: $navigateToProfileView) {
                          
                        }
                        
                        Button(action: {
                            navigateToLeaveRequestView = true
                        }) {
                            ButtonMoreView(title: "Leave Requests", icon: "calendar", color: "F5C87E")
                        }
                        .navigationDestination(isPresented: $navigateToLeaveRequestView) {
                            LeaveRequestView()
                        }
                        
                        
                        Button(action: {
                            navigateToStatisticView = true
                        }) {
                            ButtonMoreView(title: "Statistic", icon: "chart.bar", color: "8BC5A3")
                        }
                        .navigationDestination(isPresented: $navigateToStatisticView) {
                            
                            
                        }
                        
                    }
                }
                .padding(.top, 50)
                Spacer()
            }
        }
    }
}

#Preview {
    EmployeeMoreTabView()
}
