//
//  MoreTabView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI

struct MoreTabView: View {
        
    @State var navigateToAdminsView = false
    @State var navigateToEmployerView = false
    @State var navigateToAttestView = false
    @State var navigateToScheduleView = false
    @State var navigateToCompanyView = false
    @State var navigateToRequestsView = false
    
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
 
    
    var body: some View {
        NavigationStack {
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
                            Text("Admin: \(adminData.fullName)")
                                .font(.headline)
                            Text("Company Code: \(adminData.companyCode)")
                        }
                        .task {
                            // Load admin data when the view appears
                            await punchsyncfb.loadAdminData(adminData: adminData)
                        }
                    }
                }
                
                VStack(spacing: 30) {
                    // First Row with 2 buttons
                    HStack(spacing: 3) {
                        
                        Button(action: {
                            navigateToAdminsView = true
                        }) {
                            ButtonMoreView(title: "Admins", icon: "person.2.fill", color: "283B34")
                        }
                        .navigationDestination(isPresented: $navigateToAdminsView) {
                            AddAdminView(yourcompanyID: adminData.companyCode)
                        }
                        
                        Button(action: {
                            navigateToEmployerView = true
                        }) {
                            ButtonMoreView(title: "Employer", icon: "person.crop.circle.fill.badge.checkmark", color: "FE7E65")
                        }
                        .navigationDestination(isPresented: $navigateToEmployerView) {
                                EmployerView()
                        }
                    }
                    
                    // Second Row with 2 buttons
                    HStack(spacing: 3) {
                        
                        Button(action: {
                            navigateToAttestView = true
                        }) {
                            ButtonMoreView(title: "Attest", icon: "checkmark.rectangle", color: "60BDCD")
                        }
                        .navigationDestination(isPresented: $navigateToAttestView) {
                            AttestView()
                        }
                        
                        Button(action: {
                            navigateToScheduleView = true
                        }) {
                            ButtonMoreView(title: "Schedule", icon: "calendar", color: "8BC5A3")
                        }
                        .navigationDestination(isPresented: $navigateToScheduleView) {
                            ScheduleView()
                        }
                    }
                    
                    // Third Row with 2 buttons
                    HStack(spacing: 3) {
                        
                        Button(action: {
                            navigateToCompanyView = true
                        }) {
                            ButtonMoreView(title: "Company", icon: "building.2.fill", color: "F5C87E")
                        }
                        .navigationDestination(isPresented: $navigateToCompanyView) {
                            CompanyView()
                        }
                        
                        Button(action: {
                            navigateToRequestsView = true
                        }) {
                            ButtonMoreView(title: "Leave Requests", icon: "envelope.badge", color: "FE7E65")
                        }
                        .navigationDestination(isPresented: $navigateToRequestsView) {
                            RequestsView()
                        }
                    }
                }
            }
            .padding(.top, 50)
            Spacer()
        }
    }
}
            
#Preview {
    MoreTabView()
}
