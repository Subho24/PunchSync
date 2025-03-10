//
//  ProfileView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-20.
//

import SwiftUI

struct ProfileView: View {
    
    @State var punchsyncfb = PunchSyncFB()
    @StateObject private var employeeData = EmployeeData(id: "123", data: ["fullName": ""])
    
    @State var navigateToDeleteAccountView = false

    var body: some View {
        ZStack {
          
            VStack {
                Spacer().frame(height: 70)
              ProfileImage()
                
                // Korniza për secilën të dhënë
                VStack(alignment: .leading, spacing: 25) { // Shtuar hapësirë mes secilës kornizë
                    
                    // Korniza për emrin
                    HStack {
                        Text("Name:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(employeeData.fullName)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15) // Rritur radiusin e këndit
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FE7E65"), lineWidth: 0.5)) // Vijë shumë e hollë portokalli
                    
                    // Korniza për email
                    HStack {
                        Text("Email:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(employeeData.email)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15) // Rritur radiusin e këndit
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FE7E65"), lineWidth: 0.5)) // Vijë shumë e hollë portokalli
                    
                    // Korniza për kodin e kompanisë
                    HStack {
                        Text("Company Code:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(employeeData.companyCode)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15) // Rritur radiusin e këndit
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FE7E65"), lineWidth: 0.5)) // Vijë shumë e hollë portokalli
                    
                    // Korniza për numrin personal, duke fshehur 4 numrat e fundit
                    HStack {
                        Text("Personal Number:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(maskPersonalNumber(employeeData.personalNumber))
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15) // Rritur radiusin e këndit
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FE7E65"), lineWidth: 0.5)) // Vijë shumë e hollë portokalli
                }
                .padding(25) // Shtuar hapësirë rreth të dhënave
                .frame(maxWidth: .infinity) // Shtrirja përmbajtjes në të gjithë ekranin
                
                Spacer()
                
                Button(action: {
                    navigateToDeleteAccountView = true
                }) {
                    Text("Delete Account")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                }
                .navigationDestination(isPresented: $navigateToDeleteAccountView) {
                    DeleteAccountView()
                }
                .cornerRadius(16)
                .padding(.bottom, 50)
            }
        }
        .task {
            punchsyncfb.loadEmployeeData(employeeData: employeeData) { success, error in
                if success {
                    print("Employee data loaded successfully")
                } else if let error = error {
                    print("Error loading employee data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Funksioni për të fshehur 4 shifrat e fundit të numrit personal
    func maskPersonalNumber(_ number: String) -> String {
        if number.count > 4 {
            let maskedPart = String(repeating: "x", count: 4) // Maskon vetëm 4 shifrat e fundit
            let firstPart = number.prefix(number.count - 4) // Merr pjesën që nuk do të maskohet
            return firstPart + maskedPart // Bashkon pjesën e paracaktuar dhe maskën
        }
        return "xxxx" // Nëse numri është më i shkurtër se 4 shifra, kthe "xxxx"
    }
}

#Preview {
    ProfileView()
}
