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
                
                TextFieldView(placeholder: "Company Name", text: $companyname, isSecure: false, systemName: "person")
                
                TextFieldView(placeholder: "Organisation Number", text: $organisationnumber, isSecure: false, systemName: "number")
                
                TextFieldView(placeholder: "Adress", text: $adress, isSecure: false, systemName: "location")
                
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
