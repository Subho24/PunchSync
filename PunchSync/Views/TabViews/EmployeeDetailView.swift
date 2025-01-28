//
//  EmployeeDetailView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-02.
//


import SwiftUI

struct EmployeeDetailView: View {
    
    var employee: EmployeeData

    var body: some View {
        ZStack {
           
            VStack {
                Spacer().frame(height: 70)

                // Rrethi i profilit
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(LinearGradient(gradient: Gradient(colors: [
                                Color(hex: "283B34"),
                                Color(hex: "60BDCD"),
                                Color(hex: "8BC5A3"),
                                Color(hex: "F5C87E"),
                                Color(hex: "FE7E65")
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 6)
                    )
                    .shadow(radius: 6)
                    .padding(.bottom, 5)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    )

                // Kornizat me të dhënat e punonjësit
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Emri
                    HStack {
                        Text("Name:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(employee.fullName)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FE7E65"), lineWidth: 0.5))

                    // Email-i
                    HStack {
                        Text("Email:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(employee.email)
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FE7E65"), lineWidth: 0.5))

                    // Numri personal
                    HStack {
                        Text("Personal Number:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(maskPersonalNumber(employee.personalNumber))
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FE7E65"), lineWidth: 0.5))

                    // Roli
                    HStack {
                        Text("Role:")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                        Text(employee.isAdmin ? "Admin" : "Employee")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(hex: "FE7E65"), lineWidth: 0.5))
                }
                .padding(25)
                .frame(maxWidth: .infinity)

                Spacer()
            }
        }
    }

    // Funksioni për fshehjen e 4 shifrave të fundit
    func maskPersonalNumber(_ number: String) -> String {
        if number.count > 4 {
            let maskedPart = String(repeating: "x", count: 4)
            let firstPart = number.prefix(number.count - 4)
            return firstPart + maskedPart
        }
        return "xxxx"
    }
}

#Preview {
    EmployeeDetailView(employee: EmployeeData(id: "1", data: [
        "fullName": "John Doe",
        "email": "john.doe@example.com",
        "personalSecurityNumber": "12345",
        "companyCode": "AB123",
        "admin": true
    ]))
}
