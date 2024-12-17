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
    
    @State var fullname = ""
    @State var email = ""
    @State var password = ""
    @State var confirmpassword = ""
    @State var companycode = ""
    @State var personalsecuritynumber = ""
    
    @State var errorMessage = ""
    
    @State var punchsyncfb = PunchSyncFB()
    
    @State var admin: Bool = false
    
    var body: some View {
        
        VStack {
            
            Image("Icon")
                .resizable()
                .frame(width: 180, height: 180)
                .padding(.leading, 25)
            
            Text("Sign Up as Employee")
                .font(.title2)
                .padding(.vertical, 20)
            
            TextFieldView(placeholder: "Full Name", text: $fullname, isSecure: false, systemName: "person")
            
            TextFieldView(placeholder: "Personal Security Number", text: $personalsecuritynumber, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope")
            
            TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Confirm Password", text: $confirmpassword, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Company Code", text: $companycode, isSecure: false, systemName: "number")
            
            Text(errorMessage)
            
            VStack {
                Button(action: {
                    if fullname.isEmpty || personalsecuritynumber.isEmpty || email.isEmpty || password.isEmpty || confirmpassword.isEmpty || companycode.isEmpty {
                        errorMessage = "Please fill out all fields."
                    } else if password != confirmpassword {
                        errorMessage = "Passwords do not match."
                    } else {
                        punchsyncfb.userRegister(email: email, password: password) { firebaseError in
                            errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                        }
                        saveUserData()
                    }
                }) {
                    ButtonView(buttontext: "Sign Up")
                }
            }
            .padding(.vertical, 38)
        }
    }
    
    func saveUserData() {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        let userData: [String: Any] = [
            "fullName": fullname,
            "personalSecurityNumber": personalsecuritynumber,
            "email": email,
            "companyCode": companycode,
            "admin": false
        ]
        
        ref.child("users").childByAutoId().setValue(userData)
    }
}

#Preview {
    SignUpAsEmployerView()
}
