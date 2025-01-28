//
//  LoginView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI

struct LoginView: View {
    
    @State var punchsyncfb = PunchSyncFB()
    
    @State var email = ""
    @State var password = ""
    @State var emailErrorMessage = ""
    @State var passwordErrorMessage = ""
    @State var generalErrorMessage = ""
    
    @State var showForgotPassword = false
    
    var body: some View {
        
        ZStack {
            if !showForgotPassword {
                VStack {
                    Image("Icon")
                        .resizable()
                        .frame(width: 180, height: 180)
                        .padding(.leading, 25)
                    
                    Text("Log In to Your Account")
                        .font(.title2)
                        .padding(.vertical, 50)
                    
                    TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope", onChange: {
                        emailErrorMessage = ""
                        generalErrorMessage = ""
                    })
                    
                    ErrorMessageView(errorMessage: emailErrorMessage, height: 15)
                    
                    TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock", onChange: {
                        passwordErrorMessage = ""
                        generalErrorMessage = ""
                    })
                    
                    ErrorMessageView(errorMessage: passwordErrorMessage, height: 15)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            emailErrorMessage = ""
                            passwordErrorMessage = ""
                            generalErrorMessage = ""
                            password = ""
                            showForgotPassword.toggle()
                        }) {
                            Text("Forgot Password")
                        }
                    }
                    .padding(.trailing, 45)
                    
                    ErrorMessageView(errorMessage: generalErrorMessage)
                    
                    VStack {
                        Button(action: {
                            emailErrorMessage = ValidationUtils.validateEmail(email: email) ?? ""
                            passwordErrorMessage = ValidationUtils.validatePassword(password: password) ?? ""
                            
                            if emailErrorMessage.isEmpty && passwordErrorMessage.isEmpty {
                                punchsyncfb.userLogin(email: email, password: password) { firebaseError in
                                    generalErrorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                                }
                            }
                        }) {
                            ButtonView(buttontext: "Log in")
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            if showForgotPassword {
                ForgotPasswordView(isPresented: $showForgotPassword)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    LoginView()
}
