//
//  SignUpAsCompanyView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-14.
//

import SwiftUI
import Firebase

struct SignUpAsCompanyView: View {
    
    @State var punchsyncfb = PunchSyncFB()
    
    // Company registration states
    @State var companyName = ""
    @State var orgNumber = ""
    @State var companyFormDisabled = false
    
    // Admin profile states
    @State private var companyCode: String = ""
    @State var yourcompanyID = ""
    @State var fullName = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var admin: Bool = true
    
    // UI States
    @State var errorMessage = ""
    @State var showNext = false
    
    // Animation States
    @State private var companyFormOffset: CGFloat = 0
    @State private var companyFormScale: CGFloat = 1
    @State private var adminFormOffset: CGFloat = 1000 // Start off-screen
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack {
                    Image("Icon")
                        .resizable()
                        .frame(width: 180, height: 180)
                        .padding(.leading, 25)
                    
                    
                    Text(showNext ? "Your company is registered!" : "Sign Up As Company")
                        .font(.title2)
                        .padding(.vertical, 50)
                    
                    Group {
                        VStack {
                            TextFieldView(placeholder: "Company Name", text: $companyName, isSecure: false, systemName: "person", onChange: { errorMessage = ""
                            })
                                .disabled(showNext)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .opacity(showNext ? 0.8 : 1)
                            
                            TextFieldView(placeholder: "Organization Number", text: $orgNumber, isSecure: false, systemName: "number", onChange: {
                                orgNumber = ValidationUtils.formatOrgNumber(orgNumber);
                                errorMessage = ""
                            })
                            .disabled(showNext)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(showNext ? 0.8 : 1)
                        }
                        .padding(.vertical)
                        .background(showNext ? Color(.systemGray6) : Color(.systemBackground))
                        .cornerRadius(12)
                        .offset(y: companyFormOffset)
                        .scaleEffect(companyFormScale)
                        
                        if !showNext {
                            ErrorMessageView(errorMessage: errorMessage)
                            
                            Button(action: {
                                if let validationError = ValidationUtils.validatesignUpAsCompany(companyName: companyName, orgNumber: orgNumber) {
                                    errorMessage = validationError
                                } else {
                                    punchsyncfb.saveCompanyData(companyName: companyName, orgNumber: orgNumber) { success, error in
                                        if let error = error {
                                            self.errorMessage = error
                                        } else if success {
                                            withAnimation {
                                                showNext = true
                                                companyFormDisabled = true
                                            }
                                            yourcompanyID = punchsyncfb.companyCode
                                        }
                                    }
                                }
                            }) {
                                ButtonView(buttontext: "Next")
                            }
                        }
                    }
                    
                    if showNext {
                        
                        Text("You can update your company information after you have created a profile.")
                            .font(.footnote)
                            .padding(.horizontal, 45)
                            .padding(.top, -50)
                            .foregroundStyle(Color.gray)
                    
                        VStack {
                            
                            Text("Add Profile")
                                .font(.title2)
                                .padding(.vertical, 20)
                            
                            HStack {
                                Text("Your Company ID:")
                                    .padding(.leading, 45)
                                Spacer()
                            }
                            
                            TextFieldView(placeholder: "xxxxxxxxxx", text: $yourcompanyID, isSecure: false, systemName: "number")
                                .disabled(true)
                                .foregroundStyle(Color.gray)
                            
                            TextFieldView(placeholder: "Full Name", text: $fullName, isSecure: false, systemName: "person")
                            
                            TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope")
                            
                            TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock")
                            
                            TextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, systemName: "lock")
                            
                            ErrorMessageView(errorMessage: errorMessage)
                            
                            VStack {
                                Button(action: {
                                    if let validationError = ValidationUtils.validateRegisterInputs(fullName: fullName, email: email, password: password, confirmPassword: confirmPassword, companyCode: yourcompanyID) {
                                        errorMessage = validationError
                                    } else {
                                        punchsyncfb.createProfile(email: email, password: password, fullName: fullName, yourcompanyID: yourcompanyID) { firebaseError in
                                            errorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                                        }
                                    }
                                }) {
                                    ButtonView(buttontext: "Add")
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .offset(y: adminFormOffset)
                        .onAppear {
                           withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                               adminFormOffset = 0
                               companyFormOffset = -50  // Slide up
                               companyFormScale = 0.95  // Slightly reduce size
                           }
                       }
                    }
                }
                .padding(.top, 50)
            }
        }
    }
}

#Preview {
    SignUpAsCompanyView()
}
