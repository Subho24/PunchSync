//
//  SignUpAsCompanyView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI

struct SignUpAsCompanyView: View {
    
    @State var companyname = ""
    @State var organisationnumber = ""
    @State var adress = ""
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                Image("Icon")
                    .resizable()
                    .frame(width: 180, height: 180)
                    .padding(.leading, 25)
                
                Text("Sign Up As Company")
                    .font(.title2)
                    .padding(.vertical, 50)
                
                TextField("Company Name", text: $companyname)
                    .frame(height: 38)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                    )
                    .padding([.horizontal], 45)
                    .padding(.bottom, 10)
                
                TextField("Organisation Number", text: $organisationnumber)
                    .frame(height: 38)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                    )
                    .padding([.horizontal], 45)
                    .padding(.bottom, 10)
                
                TextField("Adress", text: $adress)
                    .frame(height: 38)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.8), lineWidth: 0.5) // Border with rounded corners
                    )
                    .padding([.horizontal], 45)
                    .padding(.bottom, 3)
                
                NavigationLink(destination: AddAdminView()) {
                    VStack {
                        ButtonView(buttontext: "Next")
                    }
                    .padding(.vertical, 38)
                }
                
            }
        }
    }
}

#Preview {
    SignUpAsCompanyView()
}
