//
//  AddAdminView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI

struct AddAdminView: View {
    
    @State var yourcompanyID = ""
    @State var fullname = ""
    @State var email = ""
    @State var password = ""
    @State var confirmpassword = ""
    
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
            
            TextFieldView(placeholder: "xxxxxxxxxx", text: $yourcompanyID, isSecure: false)
            
            TextFieldView(placeholder: "Full Name", text: $fullname, isSecure: false)
                
            TextFieldView(placeholder: "Email", text: $email, isSecure: false)
            
            TextFieldView(placeholder: "Password", text: $password, isSecure: true)
            
            TextFieldView(placeholder: "Confirm Password", text: $confirmpassword, isSecure: true)
            
            VStack {
                ButtonView(buttontext: "Sign Up")
            }
            .padding(.vertical, 38)
            
        }
    }
}

#Preview {
    AddAdminView()
}
