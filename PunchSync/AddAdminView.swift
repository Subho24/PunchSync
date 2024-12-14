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
            
            TextField("xxxxxxxxxx", text: $yourcompanyID)
                .frame(height: 38)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                )
                .padding([.horizontal], 45)
                .padding(.bottom, 10)
            
            TextField("Full Name", text: $fullname)
                .frame(height: 38)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                )
                .padding([.horizontal], 45)
                .padding(.bottom, 10)
            
            TextField("Email", text: $email)
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
                .padding(.bottom, 10)
            
            TextField("Confirm Password", text: $confirmpassword)
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
                ButtonView(buttontext: "Sign Up")
            }
            .padding(.vertical, 38)
            
        }
    }
}

#Preview {
    AddAdminView()
}
