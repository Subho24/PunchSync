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
    
    @State var nameErrorMessage = ""
    @State var personalNumberErrorMessage = ""
    @State var emailErrorMessage = ""
    @State var passwordErrorMessage = ""
    @State var confirmPasswordErrorMessage = ""
    @State var companyCodeErrorMessage = ""
    @State var generalErrorMessage = ""
    
    
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
                    nameErrorMessage = ""
                })
                
                ErrorMessageView(errorMessage: nameErrorMessage, height: 14)
                
                TextFieldView(placeholder: "Personal Number (12 numbers)", text: $personalNumber, isSecure: false, systemName: "lock", onChange: {
                    personalNumber = ValidationUtils.formatPersonalNumber(personalNumber);
                    personalNumberErrorMessage = ""
                })
                
                ErrorMessageView(errorMessage: personalNumberErrorMessage, height: 14)
                
                TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope", onChange: { emailErrorMessage = ""})
                
                ErrorMessageView(errorMessage: emailErrorMessage, height: 14)
                
                TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock", onChange: { passwordErrorMessage = ""})
                
                ErrorMessageView(errorMessage: passwordErrorMessage, height: 14)
                
                TextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, systemName: "lock", onChange: { confirmPasswordErrorMessage = ""})
                
                ErrorMessageView(errorMessage: confirmPasswordErrorMessage, height: 14)
                
                TextFieldView(placeholder: "Company Code", text: $companyCode, isSecure: false, systemName: "number", onChange: { companyCodeErrorMessage = ""})
                    .autocapitalization(.allCharacters) // För iOS 14 och tidigare
                    .textInputAutocapitalization(.characters)
                
                ErrorMessageView(errorMessage: companyCodeErrorMessage, height: 14)
                
                VStack {
                    Button(action: {
                        nameErrorMessage = ValidationUtils.validateName(name: fullName) ?? ""
                        personalNumberErrorMessage = ValidationUtils.validatePersonalNumber(personalNumber: personalNumber) ?? ""
                        emailErrorMessage = ValidationUtils.validateEmail(email: email) ?? ""
                        passwordErrorMessage = ValidationUtils.validatePassword(password: password) ?? ""
                        confirmPasswordErrorMessage = ValidationUtils.validateConfirmPassword(password: password, confirmPassword: confirmPassword) ?? ""
                        companyCodeErrorMessage = ValidationUtils.validateCompanyCode(companyCode: companyCode) ?? ""

                        // Kontrollera om alla valideringar är OK
                        if nameErrorMessage.isEmpty &&
                            personalNumberErrorMessage.isEmpty &&
                            emailErrorMessage.isEmpty &&
                            passwordErrorMessage.isEmpty &&
                            confirmPasswordErrorMessage.isEmpty &&
                            companyCodeErrorMessage.isEmpty {
                            
                            punchsyncfb.saveUserData(
                                fullName: fullName,
                                personalNumber: personalNumber,
                                email: email,
                                password: password,
                                companyCode: companyCode
                            ) { success, error in
                                if let error = error {
                                    // Hantera fel
                                    generalErrorMessage = error
                                } else if success {
                                    // Hantera framgång
                                    print("User registration and data saving completed successfully!")
                                }
                            }
                        }
                    }) {
                        ButtonView(buttontext: "Sign Up")
                    }
                }
                .padding(.vertical, 10)
                
                ErrorMessageView(errorMessage: generalErrorMessage)

            }
        }
    }
}

#Preview {
    SignUpAsEmployerView()
}
