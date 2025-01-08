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
    @State var errorMessage = ""
    
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
                        errorMessage = ""
                    })
                    
                    TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock", onChange: {
                        errorMessage = ""
                    })
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showForgotPassword.toggle()
                        }) {
                            Text("Forgot Password")
                        }
                    }
                    .padding(.trailing, 45)
                    
                    ErrorMessageView(errorMessage: errorMessage)
                    
                    VStack {
                        Button(action: {
                            if let validationError = ValidationUtils.validateLogin(email: email, password: password) {
                                errorMessage = validationError
                            } else {
                                punchsyncfb.userLogin(email: email, password: password) { firebaseError in
                                    errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
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
