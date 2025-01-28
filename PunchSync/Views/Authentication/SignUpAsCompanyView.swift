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
    @State var navigateToHome = false
    @State private var isCompanyRegistered: Bool = false
    
    // Company registration states
    @State var companyName = ""
    @State var orgNumber = ""
    @State var companyFormDisabled = false
    
    // Admin profile states
    @State private var companyCode: String = ""
    @State var yourcompanyID = ""
    @State var fullName = ""
    @State var personalNumber = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var admin: Bool = true
    
    // UI States
    @State var errorMessage = ""
    @State var companyNameErrorMessage = ""
    @State var orgNumberErrorMessage = ""
    @State var generalErrorMessage = ""
    
    @State var nameErrorMessage = ""
    @State var personalNumberErrorMessage = ""
    @State var emailErrorMessage = ""
    @State var passwordErrorMessage = ""
    @State var confirmPasswordErrorMessage = ""
    @State var companyCodeErrorMessage = ""
    
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
                    
                    VStack {
                        VStack {
                            TextFieldView(placeholder: "Company Name", text: $companyName, isSecure: false, systemName: "person", onChange: { companyNameErrorMessage = ""
                            })
                                .disabled(showNext)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .opacity(showNext ? 0.8 : 1)
                            
                            if !showNext {
                                ErrorMessageView(errorMessage: companyNameErrorMessage, height: 14)
                            }
                            
                            TextFieldView(placeholder: "Organization Number", text: $orgNumber, isSecure: false, systemName: "number", onChange: {
                                orgNumber = ValidationUtils.formatOrgNumber(orgNumber);
                                orgNumberErrorMessage = ""; generalErrorMessage = ""
                            })
                            .disabled(showNext)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(showNext ? 0.8 : 1)
                            
                            if !showNext {
                                ErrorMessageView(errorMessage: orgNumberErrorMessage)
                            }
                        }
                        .padding(.vertical)
                        .background(showNext ? Color(.systemGray6) : Color(.systemBackground))
                        .cornerRadius(12)
                        .offset(y: companyFormOffset)
                        .scaleEffect(companyFormScale)
                        
                        if !showNext {
                            
                            Button(action: {
                                companyNameErrorMessage = ValidationUtils.validateCompanyName(companyName: companyName) ?? ""
                                orgNumberErrorMessage = ValidationUtils.validateOrgNumber(orgNumber: orgNumber) ?? ""
                                
                                if companyNameErrorMessage.isEmpty && orgNumberErrorMessage.isEmpty {
                                    punchsyncfb.saveOrDeleteCompanyData(companyName: companyName, orgNumber: orgNumber, delete: false) { success, error in
                                        if let error = error {
                                            self.generalErrorMessage = error
                                        } else if success {
                                            isCompanyRegistered = true
                                            withAnimation {
                                                showNext = true
                                                companyFormDisabled = true
                                            }
                                            yourcompanyID = punchsyncfb.companyCode
                                            generalErrorMessage = ""
                                        }
                                    }
                                }
                            }) {
                                ButtonView(buttontext: "Next")
                            }
                            
                            ErrorMessageView(errorMessage: generalErrorMessage)
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
                                .padding(.bottom, 14)
                            
                            TextFieldView(placeholder: "Full Name", text: $fullName, isSecure: false, systemName: "person", onChange: { nameErrorMessage = ""})
                            
                            ErrorMessageView(errorMessage: nameErrorMessage, height: 14)
                            
                            TextFieldView(placeholder: "Personal Number (12 numbers)", text: $personalNumber, isSecure: false, systemName: "lock", onChange: {
                                personalNumber = ValidationUtils.formatPersonalNumber(personalNumber);
                                personalNumberErrorMessage = ""
                            })
                            
                            ErrorMessageView(errorMessage: personalNumberErrorMessage, height: 14)

                            TextFieldView(placeholder: "Email", text: $email, isSecure: false, systemName: "envelope", onChange: { emailErrorMessage = ""})
                            
                            ErrorMessageView(errorMessage: emailErrorMessage, height: 14)
                            
                            TextFieldView(placeholder: "Password", text: $password, isSecure: true, systemName: "lock", onChange: { passwordErrorMessage = ""})
                            
                            ErrorMessageView(errorMessage: passwordErrorMessage, height: 14)
                            
                            TextFieldView(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true, systemName: "lock",  onChange: { confirmPasswordErrorMessage = ""})
                            
                            ErrorMessageView(errorMessage: confirmPasswordErrorMessage, height: 14)
                            
                            VStack {
                                Button(action: {
                                    nameErrorMessage = ValidationUtils.validateName(name: fullName) ?? ""
                                    personalNumberErrorMessage = ValidationUtils.validatePersonalNumber(personalNumber: personalNumber) ?? ""
                                    emailErrorMessage = ValidationUtils.validateEmail(email: email) ?? ""
                                    passwordErrorMessage = ValidationUtils.validatePassword(password: password) ?? ""
                                    confirmPasswordErrorMessage = ValidationUtils.validateConfirmPassword(password: password, confirmPassword: confirmPassword) ?? ""
                                    
                                    if nameErrorMessage.isEmpty &&
                                        personalNumberErrorMessage.isEmpty &&
                                        emailErrorMessage.isEmpty &&
                                        passwordErrorMessage.isEmpty &&
                                        confirmPasswordErrorMessage.isEmpty {
                                        
                                        punchsyncfb.createProfile(email: email, password: password, fullName: fullName, personalNumber: personalNumber, yourcompanyID: yourcompanyID) { firebaseError in
                                            generalErrorMessage = firebaseError ?? "" // Default to empty string if no Firebase error
                                        }
                                    }
                                    
                                }) {
                                    ButtonView(buttontext: "Add")
                                }
                            }
                            .padding(.vertical, 10)
                            
                            ErrorMessageView(errorMessage: generalErrorMessage)
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
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            if isCompanyRegistered {
                                punchsyncfb.saveOrDeleteCompanyData(
                                    orgNumber: orgNumber,
                                    delete: true
                                ) { success, message in
                                    if success {
                                        print("Company deleted successfully!")
                                    } else {
                                        print(message ?? "Unknown error")
                                    }
                                }
                            }
                            navigateToHome = true
                        }) {
                            Text("< Back")
                        }
                        .navigationDestination(isPresented: $navigateToHome) {
                            UnloggedView()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpAsCompanyView()
}
