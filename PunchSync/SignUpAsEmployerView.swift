//
//  SignUpAsEmployerView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpAsEmployerView: View {
    
    @State var fullName = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var companyCode = ""
    @State var personalNumber = ""
    
    @State var errorMessage = ""
    
    @State var punchsyncfb = PunchSyncFB()
    
    @State var admin: Bool = false
    
    var body: some View {
        
        VStack {
            
            Image("Icon")
                .resizable()
                .frame(width: 180, height: 180)
                .padding(.leading, 25)
            
            Text("Sign Up as Employee")
                .font(.title2)
                .padding(.vertical, 20)
            
            TextFieldView(placeholder: "Full Name", text: $fullName, isSecure: false, systemName: "person")
            
            TextFieldView(placeholder: "Personal Number (12 numbers)", text: $personalNumber, isSecure: false, systemName: "lock", onChange: {
                personalNumber = ValidationUtils.formatPersonalNumber(personalNumber)
            })
            
            TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope")
            
            TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Company Code", text: $companyCode, isSecure: false, systemName: "number")
            
            Text(errorMessage)
            
            VStack {
                Button(action: {
                    if let validationError = ValidationUtils.validateRegisterInputs(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword, companyCode: companyCode, personalNumber: personalNumber) {
                        errorMessage = validationError
                    } else {
                        punchsyncfb.userRegister(email: email, password: password) { firebaseError in
                            errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                        }
                        punchsyncfb.saveUserData(fullName: fullName, personalNumber: personalNumber, email: email, companyCode: companyCode)
                    }
                }) {
                    ButtonView(buttontext: "Sign Up")
                }
            }
            .padding(.vertical, 38)
        }
    }
}

#Preview {
    SignUpAsEmployerView()
}
