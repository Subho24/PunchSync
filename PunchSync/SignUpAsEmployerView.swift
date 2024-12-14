//
//  SignUpAsEmployerView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI

struct SignUpAsEmployerView: View {
    
    @State var fullname = ""
    @State var email = ""
    @State var password = ""
    @State var confirmpassword = ""
    @State var companycode = ""
    
    var body: some View {
        
        VStack {
            
            Image("Icon")
                .resizable()
                .frame(width: 180, height: 180)
                .padding(.leading, 25)
            
            Text("Sign Up as Employer")
                .font(.title2)
                .padding(.vertical, 20)
            
            TextFieldView(placeholder: "Full Name", text: $fullname, isSecure: false, systemName: "person")
            
            TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope")
            
            TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Confirm Password", text: $confirmpassword, isSecure: true, systemName: "lock")
            
            TextFieldView(placeholder: "Company Code", text: $companycode, isSecure: false, systemName: "number")
            
            VStack {
                ButtonView(buttontext: "Sign Up")
            }
            .padding(.vertical, 38)
            
        }
    }
}

#Preview {
    SignUpAsEmployerView()
}
