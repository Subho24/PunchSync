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
        
        ScrollView {
            VStack {
                Image("Icon")
                    .resizable()
                    .frame(width: 180, height: 180)
                    .padding(.leading, 25)
                
                Text("Sign Up as Employee")
                    .font(.title2)
                    .padding(.vertical, 20)
                
                TextFieldView(placeholder: "Full Name", text: $fullName, isSecure: false, systemName: "person", onChange: {
                    errorMessage = ""
                })
                
                TextFieldView(placeholder: "Personal Number (12 numbers)", text: $personalNumber, isSecure: false, systemName: "lock", onChange: {
                    personalNumber = ValidationUtils.formatPersonalNumber(personalNumber);
                    errorMessage = ""
                })
                
                TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope", onChange: { errorMessage = ""})
                
                TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock", onChange: { errorMessage = ""})
                
                TextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, systemName: "lock", onChange: { errorMessage = ""})
                
                TextFieldView(placeholder: "Company Code", text: $companyCode, isSecure: false, systemName: "number", onChange: { errorMessage = ""})
                    .autocapitalization(.allCharacters) // För iOS 14 och tidigare
                    .textInputAutocapitalization(.characters)
                
                ErrorMessageView(errorMessage: errorMessage)
                
                VStack {
                    Button(action: {
                        if let validationError = ValidationUtils.validateRegisterInputs(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword, companyCode: companyCode, personalNumber: personalNumber) {
                            errorMessage = validationError
                        } else {
                            punchsyncfb.saveUserData(fullName: fullName, personalNumber: personalNumber, email: email, companyCode: companyCode) { success, error in
                                if let error = error {
                                    self.errorMessage = error
                                } else if success {
                                    punchsyncfb.userRegister(email: email, password: password) { firebaseError in
                                        errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                                    }
                                }
                            }
                        }
                    }) {
                        ButtonView(buttontext: "Sign Up")
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
}

#Preview {
    SignUpAsEmployerView()
}
