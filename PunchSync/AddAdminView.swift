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
    @State var fullname = ""
    @State var email = ""
    @State var password = ""
    @State var confirmpassword = ""
    
    @State var errorMessage = ""
    
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
            
            TextFieldView(placeholder: "Full Name", text: $fullname, isSecure: false, systemName: "person")
                
            TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope")
            
            TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Confirm Password", text: $confirmpassword, isSecure: true, systemName: "lock")
            
            VStack {
                Button(action: {
                    punchsyncfb.userRegister(email: email, password: password) { firebaseError in
                        errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                    }
                }) {
                    ButtonView(buttontext: "Sign Up")
                }
            }
            .padding(.vertical, 38)
            
        }
    }
}

#Preview {
    AddAdminView()
}
