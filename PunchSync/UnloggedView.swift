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
                    Text("Log in")
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 12)
                        .frame(minWidth: 190.0)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FE7E65"), // Start color
                                    Color(hex: "E58D35"), // Middle color
                                    Color(hex: "FD9709")  // End color
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .cornerRadius(12)
                        .padding(.top, 30)
                }
                
                NavigationLink(destination: SignUpAsCompanyView()) {
                    Text("Sign Up as Company")
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 12)
                        .frame(minWidth: 190.0)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FE7E65"), // Start color
                                    Color(hex: "E58D35"), // Middle color
                                    Color(hex: "FD9709")  // End color
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .cornerRadius(12)
                        .padding()
               }
                
                NavigationLink(destination: SignUpAsEmployerView()) {
                    Text("Sign Up as Employee")
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 12)
                        .frame(minWidth: 190.0)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "FE7E65"), // Start color
                                    Color(hex: "E58D35"), // Middle color
                                    Color(hex: "FD9709")  // End color
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .cornerRadius(12)
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
