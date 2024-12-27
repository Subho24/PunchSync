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
    
    @State var punchsyncfb = PunchSyncFB()
    
    @State var yourcompanyID = ""
    @State var fullName = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    
    @State var errorMessage = ""
    
    @State var admin: Bool = true
    
    @State var showAlert = false
    
    var body: some View {
        
        VStack {
            
            Image("Icon")
                .resizable()
                .frame(width: 120, height: 120)
                .padding(.leading, 25)
            
            Text("Add Admin")
                .font(.title2)
                .padding(.vertical, 20)
            
            TextFieldView(placeholder: "Company Code", text: $yourcompanyID, isSecure: false, systemName: "number")
            
            TextFieldView(placeholder: "Full Name", text: $fullName, isSecure: false, systemName: "person")
                
            TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope")
            
            TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, systemName: "lock")
            
            ErrorMessageView(errorMessage: errorMessage)
            
            VStack {
                Button(action: {
                    
                    // First get the current logged-in admin
                    guard let currentAdmin = Auth.auth().currentUser else {
                        errorMessage = "No admin is currently logged in"
                        return
                    }
                    if let validationError = ValidationUtils.validateRegisterInputs(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword, companyCode: yourcompanyID) {
                        errorMessage = validationError
                    } else {
                        showAlert = true
                        punchsyncfb.createNewAdmin(email: email, password: password, fullName: fullName, yourcompanyID: yourcompanyID, currentAdmin: currentAdmin) { firebaseError in
                            errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                        }
                    }
                }) {
                    ButtonView(buttontext: "Sign Up")
                }
            }
            .alert("New Admin Created", isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    // Optional: Clear the form fields after successful creation
                    email = ""
                    password = ""
                    confirmPassword = ""
                    fullName = ""
                }
            } message: {
                Text("\(fullName) has been added as an admin.")
            }
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    AddAdminView()
}
