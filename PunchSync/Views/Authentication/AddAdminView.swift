//
//  AddAdminView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct AddAdminView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var punchsyncfb = PunchSyncFB()
    
    @State var yourcompanyID = ""
    @State var fullName = ""
    @State var personalNumber = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var addedAdminName: String = ""
    
    @State var generalErrorMessage = ""
    @State var nameErrorMessage = ""
    @State var personalNumberErrorMessage = ""
    @State var emailErrorMessage = ""
    @State var passwordErrorMessage = ""
    @State var confirmPasswordErrorMessage = ""
    
    @State var admin: Bool = true
    
    @State var showAlert = false
    
    @Binding var currentAdminPassword: String 
    @State var showAdminForm = false
    
    // Animation States
    @State private var passwordFormOffset: CGFloat = 0
    @State private var passwordFormScale: CGFloat = 1
    @State private var adminFormOffset: CGFloat = 1000 // Start off-screen
    
    var body: some View {
        
        ScrollView {
            VStack {
                Spacer()
                
                VStack {
                    LockedView(parentAdminPassword: $currentAdminPassword, showAdminForm: $showAdminForm)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, showAdminForm ? 0 : 100)
                
                Spacer()
                
                
                if showAdminForm {
                    
                    VStack {
                        Text("Add Admin")
                            .font(.title2)
                            .padding(.vertical, 20)
                        
                        TextFieldView(placeholder: "Company Code", text: $yourcompanyID, isSecure: false, systemName: "number")
                            .disabled(true)
                            .padding(.bottom, 14)
                        
                        TextFieldView(placeholder: "Full Name", text: $fullName, isSecure: false, systemName: "person", onChange: { nameErrorMessage = ""})
                        
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
                        
                        VStack {
                            Button(action: {
                                
                                // First get the current logged-in admin
                                guard let currentAdmin = Auth.auth().currentUser else {
                                    generalErrorMessage = "No admin is currently logged in"
                                    return
                                }
                                
                                // Validate admin password
                                guard !currentAdminPassword.isEmpty else {
                                    generalErrorMessage = "Please enter your admin password"
                                    return
                                }
                                
                                nameErrorMessage = ValidationUtils.validateName(name: fullName) ?? ""
                                personalNumberErrorMessage = ValidationUtils.validatePersonalNumber(personalNumber: personalNumber) ?? ""
                                emailErrorMessage = ValidationUtils.validateEmail(email: email) ?? ""
                                passwordErrorMessage = ValidationUtils.validatePassword(password: password) ?? ""
                                confirmPasswordErrorMessage = ValidationUtils.validateConfirmPassword(password: password, confirmPassword: confirmPassword) ?? ""
                                
                                if nameErrorMessage.isEmpty &&
                                    personalNumberErrorMessage.isEmpty &&
                                    emailErrorMessage.isEmpty &&
                                    passwordErrorMessage.isEmpty &&
                                    confirmPasswordErrorMessage.isEmpty {
                                    
                                    punchsyncfb.createNewAdmin(email: email, password: password, fullName: fullName, personalNumber: personalNumber, yourcompanyID: yourcompanyID, currentAdmin: currentAdmin,  adminPassword: currentAdminPassword) { firebaseError in
                                        if let error = firebaseError {
                                            generalErrorMessage = error
                                        } else {
                                            generalErrorMessage = ""
                                            showAlert = true
                                            addedAdminName = fullName
                                            // Clear form fields only on success
                                            email = ""
                                            password = ""
                                            confirmPassword = ""
                                            fullName = ""
                                            personalNumber = ""
                                            currentAdminPassword = ""
                                        }
                                    }
                                }
                            }) {
                                ButtonView(buttontext: "Add")
                            }
                        }
                        .alert("New Admin Created", isPresented: $showAlert) {
                            Button("OK", role: .cancel) {
                                dismiss()
                            }
                        } message: {
                            Text("\(addedAdminName) has been added as an admin.")
                        }
                        .padding(.vertical, 10)
                        
                        ErrorMessageView(errorMessage: generalErrorMessage)
                    }
                    .offset(y: adminFormOffset)
                    .onAppear {
                       withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                           adminFormOffset = 0
                           passwordFormOffset = -50  // Slide up
                           passwordFormScale = 0.95  // Slightly reduce size
                       }
                   }
                }
            }
        }
    }
}

#Preview {
    AddAdminView(currentAdminPassword: .constant(""))
}
