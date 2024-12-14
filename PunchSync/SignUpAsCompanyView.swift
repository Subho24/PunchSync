//
//  SignUpAsCompanyView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI
import Firebase

struct SignUpAsCompanyView: View {
    
    @State var companyName = ""
    @State var organizationNumber = ""
    @State var address = ""
    
    @State private var navigateToAddAdmin = false
    @State private var companyCode: String = ""
    
    @State var errorMessage: String?
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                Image("Icon")
                    .resizable()
                    .frame(width: 180, height: 180)
                    .padding(.leading, 25)
                
                Text("Sign Up As Company")
                    .font(.title2)
                    .padding(.vertical, 50)
                
                TextFieldView(placeholder: "Company Name", text: $companyName, isSecure: false, systemName: "person")
                
                TextFieldView(placeholder: "Organization Number", text: $organizationNumber, isSecure: false, systemName: "number")
                
                TextFieldView(placeholder: "Address", text: $address, isSecure: false, systemName: "location")
                
                Text(errorMessage ?? "")
                    .frame(height: 20)
               
                Button(action: {
                    if companyName.isEmpty || organizationNumber.isEmpty || address.isEmpty {
                        errorMessage = "Please fill in all fields"
                        navigateToAddAdmin = false
                    } else {
                        saveCompanyData()
                        navigateToAddAdmin = true
                        companyName = ""
                        organizationNumber = ""
                        address = ""
                    }
                }) {
                    ButtonView(buttontext: "Next")
                }
                .navigationDestination(isPresented: $navigateToAddAdmin) {
                    AddAdminView(yourcompanyID: companyCode)
                }
                .padding(.vertical, 38)
            }
        }
    }
    
    func saveCompanyData() {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        func generateCompanyCode() -> String {
            let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<10).map { _ in characters.randomElement()! })
        }
        
        let newCompanyCode = generateCompanyCode()
        self.companyCode = newCompanyCode
        
        let companyData: [String: Any] = [
            "companyName": companyName,
            "organizationNumber": organizationNumber,
            "address": address,
            "companyCode": newCompanyCode,
        ]
        
        ref.child("companies").childByAutoId().setValue(companyData)
    }
}

#Preview {
    SignUpAsCompanyView()
}
