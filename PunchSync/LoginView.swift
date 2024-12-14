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
            
            TextField("Username or Email", text: $username)
                .frame(height: 38)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                )
                .padding([.horizontal], 45)
                .padding(.bottom, 10)
            
            TextField("Password", text: $password)
                .frame(height: 38)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                )
                .padding([.horizontal], 45)
                .padding(.bottom, 3)
            
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
