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
    
    var body: some View {
        
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
}

#Preview {
    LoginView()
}
