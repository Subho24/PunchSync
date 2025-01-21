//
//  LockedView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-13.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LockedView: View {
    
    @State var errorMessage = ""
    
    @State private var currentAdminPassword: String = ""
    @Binding var showAdminForm: Bool
    @State private var isAuthenticating = false
    
    // Animation States
    @State private var passwordFormOffset: CGFloat = 0
    @State private var passwordFormScale: CGFloat = 1
    @State private var adminFormOffset: CGFloat = 1000 // Start off-screen
    
    var body: some View {
        
        VStack {
            
            Image("Icon")
                .resizable()
                .frame(width: 180, height: 180)
                .padding(.leading, 25)
                .padding(.bottom, showAdminForm ? 50 : 30)
            
            TextFieldView(placeholder: "Enter your password", text: $currentAdminPassword, isSecure: true , systemName: "lock", onChange: { errorMessage = ""})
                .padding(.top, 35)
                .padding(.bottom, showAdminForm ? 35 : 0)
                .disabled(showAdminForm)
                .background(showAdminForm ? Color(.systemGray6) : Color(.systemBackground))
                .cornerRadius(12)
                .offset(y: passwordFormOffset)
                .scaleEffect(passwordFormScale)
            
            if !showAdminForm {
                
                ErrorMessageView(errorMessage: errorMessage)
                
                Button(action: {
                    guard let currentAdmin = Auth.auth().currentUser else {
                        errorMessage = "No admin is currently logged in"
                        return
                    }
                    
                    guard !currentAdminPassword.isEmpty else {
                        errorMessage = "Please enter your admin password"
                        return
                    }
                    
                    errorMessage = "" // Töm eventuella tidigare felmeddelanden
                    isAuthenticating = true // Markera att autentisering pågår
                    
                    let currentAdminEmail = currentAdmin.email ?? ""
                    let adminPassword = currentAdminPassword
                    
                    let credential = EmailAuthProvider.credential(withEmail: currentAdminEmail, password: adminPassword)
                    
                    currentAdmin.reauthenticate(with: credential) { success, error in
                        DispatchQueue.main.async {
                            isAuthenticating = false // Autentisering är klar
                            
                            if let error = error {
                                // Fel vid lösenordsverifiering
                                errorMessage = "Current admin password is incorrect"
                            } else {
                                withAnimation {
                                    showAdminForm = true
                                }
                                // Lösenord verifierat korrekt
                                errorMessage = ""
                            }
                        }
                    }
                }) {
                    ButtonView(buttontext: isAuthenticating ? "Authenticating..." : "Enter")
                }
            }
        }
    }
}

#Preview {
    LockedView(showAdminForm: .constant(false))
}
