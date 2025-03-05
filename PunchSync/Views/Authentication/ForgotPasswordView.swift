//
//  ForgotPasswordView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-08.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @Binding var isPresented: Bool
    @State var punchsyncfb = PunchSyncFB()
    
    @State var email = ""
    @State var errorMessage = ""
    @State var successMessage: String?
    
    @State var deletingAccountReset: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Text("x")
                        .font(.title)
                }
            }
            .padding(.trailing, 35)
            .padding(.bottom, 20)
            
            Text("Reset Password")
                .font(.title2)
                .padding(.bottom, 50)
                .foregroundColor(Color("PrimaryTextColor"))
                
            TextFieldView(placeholder: "Email", text: $email, systemName: "envelope", onChange: {
                errorMessage = ""
            })
            
            VStack {
                if errorMessage != "" {
                    ErrorMessageView(errorMessage: errorMessage)
                } else if let successMessage = successMessage {
                    Text(successMessage)
                        .foregroundColor(.blue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .frame(height: 50)
            
            Button(action: {
                if let validationError = ValidationUtils.validateReset(email: email) {
                    errorMessage = validationError
                    successMessage = nil
                } else {
                    punchsyncfb.forgotPassword(email: email) { firebaseError in
                        if let firebaseError = firebaseError {
                            errorMessage = firebaseError
                            successMessage = nil
                        } else {
                            successMessage = deletingAccountReset ? "Please check your email. Once password is reset, return to delete your account." : "If the email you provided is registered, we've sent a reset link to your inbox."
                            email = ""
                            errorMessage = firebaseError ?? "" // Clear error on success
                        }
                    }
                }
            }) {
                ButtonView(buttontext: "Send Reset Link")
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 330)
        .background(Color(hex: "B5D8C3"))
        .cornerRadius(20)
        .shadow(radius: 10, x: 5, y: 5)

    }
}

#Preview {
    ForgotPasswordView(isPresented: .constant(true), deletingAccountReset: false)
}
