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
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var addedAdminName: String = ""
    
    @State var errorMessage = ""
    
    @State var admin: Bool = true
    
    @State var showAlert = false
    
    @State private var currentAdminPassword: String = ""
    @State var showAdminForm = false
    @State private var isAuthenticating = false
    
    var body: some View {
        
        ScrollView {
            VStack {
                
                VStack {
                    
                    Image("Icon")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .padding(.leading, 25)
                    
                    TextFieldView(placeholder: "Your own password", text: $currentAdminPassword, isSecure: true , systemName: "lock", onChange: { errorMessage = ""})
                        .padding(.top, 35)
                        .disabled(showAdminForm)
                    
                    if !showAdminForm {
                        
                        ErrorMessageView(errorMessage: errorMessage)
                        
                        Button(action: {
                            guard let currentAdmin = Auth.auth().currentUser else {
                                errorMessage = "No admin is currently logged in"
                                return
                            }
                            
                            guard !currentAdminPassword.isEmpty else {
                                errorMessage = "Please enter your admin password"
                                return
                            }
                            
                            errorMessage = "" // Töm eventuella tidigare felmeddelanden
                            isAuthenticating = true // Markera att autentisering pågår
                            
                            let currentAdminEmail = currentAdmin.email ?? ""
                            let adminPassword = currentAdminPassword
                            
                            let credential = EmailAuthProvider.credential(withEmail: currentAdminEmail, password: adminPassword)
                            
                            currentAdmin.reauthenticate(with: credential) { _, error in
                                DispatchQueue.main.async {
                                    isAuthenticating = false // Autentisering är klar
                                    
                                    if let error = error {
                                        // Fel vid lösenordsverifiering
                                        errorMessage = "Current admin password is incorrect"
                                    } else {
                                        // Lösenord verifierat korrekt
                                        errorMessage = ""
                                        showAdminForm = true
                                    }
                                }
                            }
                        }) {
                            ButtonView(buttontext: isAuthenticating ? "Authenticating..." : "Enter")
                        }
                    }
                }
                
                
                if showAdminForm {
                    Text("Add Admin")
                        .font(.title2)
                        .padding(.vertical, 20)
                    
                    TextFieldView(placeholder: "Company Code", text: $yourcompanyID, isSecure: false, systemName: "number")
                        .disabled(true)
                    
                    TextFieldView(placeholder: "Full Name", text: $fullName, isSecure: false, systemName: "person", onChange: { errorMessage = ""})
                    
                    TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope", onChange: { errorMessage = ""})
                    
                    TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock", onChange: { errorMessage = ""})
                    
                    TextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, systemName: "lock", onChange: { errorMessage = ""})
                    
                    ErrorMessageView(errorMessage: errorMessage)
                    
                    VStack {
                        Button(action: {
                            
                            // First get the current logged-in admin
                            guard let currentAdmin = Auth.auth().currentUser else {
                                errorMessage = "No admin is currently logged in"
                                return
                            }
                            
                            // Validate admin password
                            guard !currentAdminPassword.isEmpty else {
                                errorMessage = "Please enter your admin password"
                                return
                            }
                            
                            if let validationError = ValidationUtils.validateRegisterInputs(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword, companyCode: yourcompanyID) {
                                errorMessage = validationError
                            } else {
                                punchsyncfb.createNewAdmin(email: email, password: password, fullName: fullName, yourcompanyID: yourcompanyID, currentAdmin: currentAdmin,  adminPassword: currentAdminPassword) { firebaseError in
                                    if let error = firebaseError {
                                        errorMessage = error
                                    } else {
                                        errorMessage = ""
                                        showAlert = true
                                        addedAdminName = fullName
                                        // Clear form fields only on success
                                        email = ""
                                        password = ""
                                        confirmPassword = ""
                                        fullName = ""
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
                            // Optional: Clear the form fields after successful creation
                            email = ""
                            password = ""
                            confirmPassword = ""
                            fullName = ""
                            dismiss()
                        }
                    } message: {
                        Text("\(addedAdminName) has been added as an admin.")
                    }
                    .padding(.vertical, 10)
                }
            }
        }
    }
}

#Preview {
    AddAdminView()
}
