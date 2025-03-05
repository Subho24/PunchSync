//
//  PasswordConfirmationView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-03-05.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct PasswordConfirmationView: View {
    
    @State private var password = ""
    @State private var confirmationText = ""
    @State var errorMessage = ""
    
    var body: some View {
        
        VStack {
            
            Text("Confirm Deletion")
                .font(.title2)
                .foregroundStyle(Color("PrimaryTextColor"))
                .padding(.bottom, 35)
            
            TextFieldView(placeholder: String(localized: "Type DELETE to confirm"), text: $confirmationText, systemName: "trash.circle")
                .padding(.bottom, 10)
            
            TextFieldView(placeholder: String(localized: "Current Password"), text: $password, isSecure: true, systemName: "lock", onChange: { errorMessage = "" })
            
            ErrorMessageView(errorMessage: errorMessage, height: 30)
            
            Button("Delete Account") {
                deleteAccount(password: password)
            }
            .disabled(confirmationText != "DELETE")
            .buttonStyle(.borderedProminent)
            .tint(Color.red)
        }
    }
    
    private func deleteAccount(password: String) {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return
        }
        
        errorMessage = ""
        
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: password)
        
        user.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                errorMessage = "Password is incorrect"
                print("Re-authentication failed: \(error.localizedDescription)")
                return
            }
          
            let userId = user.uid
            let databaseRef = Database.database().reference()
            
            databaseRef.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
                guard let userData = snapshot.value as? [String: Any],
                      let companyCode = userData["companyCode"] as? String,
                      let personalNumber = userData["personalSecurityNumber"] as? String else {
                    print("Could not fetch companyCode or personalNumber.")
                    return
                }
                
                let paths = [
                    "users/\(userId)"
                ]
                
                let group = DispatchGroup()
                
                for path in paths {
                    group.enter()
                    databaseRef.child(path).removeValue { error, _ in
                        if let error = error {
                            print("Failed to delete data at \(path): \(error.localizedDescription)")
                        } else {
                            print("Successfully deleted data at \(path)")
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    user.delete { error in
                        if let error = error {
                            print("Account deletion failed: \(error.localizedDescription)")
                        } else {
                            print("Account successfully deleted from Firebase Authentication.")
                        }
                    }
                }
            }
        }
    }


}

#Preview {
    PasswordConfirmationView()
}

