//
//  UnloggedView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI

struct UnloggedView: View {
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                Text("PunchSync")
                    .font(.largeTitle)
                    .padding()
                Text("Manage work schedules and track your team's performance effortlessly")
                    .multilineTextAlignment(.center)
                    .padding()
                    .font(.title3)
                
                NavigationLink(destination: LoginView()) {
                    ButtonView(buttontext: "Log in")
                }
                
                NavigationLink(destination: SignUpAsCompanyView()) {
                    ButtonView(buttontext: "Sign Up as Company")
               }
                
                NavigationLink(destination: SignUpAsEmployerView()) {
                    ButtonView(buttontext: "Sign Up as Employer")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
        }
    }
}

#Preview {
    UnloggedView()
}
