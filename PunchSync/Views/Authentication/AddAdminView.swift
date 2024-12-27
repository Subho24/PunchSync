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
    
    var body: some View {
        
        VStack {
            
            Image("Icon")
                .resizable()
                .frame(width: 180, height: 180)
                .padding(.leading, 25)
            
            Text("Add Admin")
                .font(.title2)
                .padding(.vertical, 20)
            
            HStack {
                Text("Your Company ID:")
                    .padding(.leading, 45)
                Spacer()
            }
            
            TextFieldView(placeholder: "xxxxxxxxxx", text: $yourcompanyID, isSecure: false, systemName: "number")
                .disabled(yourcompanyID != "")
                .foregroundStyle(Color.gray)
            
            TextFieldView(placeholder: "Full Name", text: $fullName, isSecure: false, systemName: "person")
                
            TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope")
            
            TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, systemName: "lock")
            
            ErrorMessageView(errorMessage: errorMessage)
            
            VStack {
                Button(action: {
                    if let validationError = ValidationUtils.validateRegisterInputs(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword, companyCode: yourcompanyID) {
                        errorMessage = validationError
                    } else {
                        punchsyncfb.createNewAdmin(email: email, password: password, fullName: fullName, yourcompanyID: yourcompanyID) { firebaseError in
                            errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                        }
                    }
                }) {
                    ButtonView(buttontext: "Sign Up")
                }
            }
            .padding(.vertical, 10)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    AddAdminView()
}
