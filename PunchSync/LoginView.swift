//
//  LoginView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI

struct LoginView: View {
    
    @State var username = ""
    @State var password = ""
    
    var body: some View {
        
        VStack {
            
            Image("Icon")
                .resizable()
                .frame(width: 180, height: 180)
                .padding(.leading, 25)
            
            Text("Log In to Your Account")
                .font(.title2)
                .padding(.vertical, 50)
            
            TextFieldView(placeholder: "Username or Email", text: $username, isSecure: false)
            
            TextFieldView(placeholder: "Password", text: $password, isSecure: true)
            
            VStack {
                ButtonView(buttontext: "Log in")
            }
            .padding(.vertical, 38)
            
        }
        
    }
}

#Preview {
    LoginView()
}
