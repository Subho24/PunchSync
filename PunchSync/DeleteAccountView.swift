//
//  DeleteAccountView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-03-05.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @State var showForgotPassword = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !showForgotPassword {
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.largeTitle)
                            
                            Text("Warning: Account Deletion")
                                .font(.headline)
                                .foregroundColor(.orange)
                            
                            Text("This action cannot be undone. All your data will be permanently deleted.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 30)
                    
                        PasswordConfirmationView()
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                showForgotPassword.toggle()
                            }
                        }) {
                            ButtonView(buttontext: "Forgot password")
                        }
                       
                        
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Delete Account")
                    .navigationBarTitleDisplayMode(.inline)
                    
                } else {
                    Color.clear
                }
                
                if showForgotPassword {
                    ForgotPasswordView(isPresented: $showForgotPassword)
                        .navigationBarBackButtonHidden(true)
                        .frame(height: 350)
                        .padding(.horizontal, 24)
                        .cornerRadius(12)
                }
            }
        }
    }
}

#Preview {
    DeleteAccountView()
}
