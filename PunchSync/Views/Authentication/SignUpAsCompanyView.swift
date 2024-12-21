//
//  SignUpAsCompanyView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI
import Firebase

struct SignUpAsCompanyView: View {
    
    @State var punchsyncfb = PunchSyncFB()
    
    @State var companyName = ""
    @State var orgNumber = ""
    
    @State private var navigateToAddAdmin = false
    @State private var companyCode: String = ""
    
    @State var errorMessage = ""
    
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
                
                TextFieldView(placeholder: "Organization Number", text: $orgNumber, isSecure: false, systemName: "number", onChange: {
                    orgNumber = ValidationUtils.formatOrgNumber(orgNumber)
                })
                
                ErrorMessageView(errorMessage: errorMessage)
                
                Button(action: {
                    if let validationError = ValidationUtils.validatesignUpAsCompany(companyName: companyName, orgNumber: orgNumber) {
                        errorMessage = validationError
                    } else {
                        punchsyncfb.saveCompanyData(companyName: companyName, orgNumber: orgNumber) { success, error in
                            if let error = error {
                                   self.errorMessage = error
                               } else if success {
                                   navigateToAddAdmin = true
                                   self.companyName = ""
                                   self.orgNumber = ""
                               }
                        }
                    }
                }) {
                    ButtonView(buttontext: "Next")
                }
                .navigationDestination(isPresented: $navigateToAddAdmin) {
                    AddAdminView(yourcompanyID: punchsyncfb.companyCode)
                }
                .padding(.vertical, 10)
            }
        }
    }
}

#Preview {
    SignUpAsCompanyView()
}
