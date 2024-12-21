//
//  PunchSyncFB.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-16.
//

import Foundation
import Firebase
import FirebaseAuth

@Observable class PunchSyncFB {
    
    func userLogin(email : String, password : String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                try await Auth.auth().signIn(withEmail: email, password: password)
                print("Successfully logged in")
                completion(nil)
            } catch {
                print("Login failed: \(error.localizedDescription)")
                completion(error.localizedDescription) // Return Firebase error
            }
        }
    }
    
    func userRegister(email: String, password: String, completion: @escaping (String?) -> Void) {
        Task {
            do {
                let regResult = try await Auth.auth().createUser(withEmail: email, password: password)
                print("Registration successful for user: \(regResult.user.email ?? "Unknown")")
                completion(nil)
            } catch {
                print("Registration failed: \(error.localizedDescription)")
                completion(error.localizedDescription) // Return Firebase error
            }
        }
    }
    
    func userLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
    }
    
    func saveAdminData(fullName: String, email: String, yourcompanyID: String) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        let userData: [String: Any] = [
            "fullName": fullName,
            "email": email,
            "companyCode": yourcompanyID,
            "admin": true
        ]
        
        ref.child("users").childByAutoId().setValue(userData)
    }
    
    func saveUserData(fullName: String, personalNumber: String, email: String, companyCode: String, completion: @escaping (Bool, String?) -> Void) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        //First check if the personal number is already registered
        ref.child("users").child(personalNumber).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(false, "Personal number already registered.")
            } else {
                let userData: [String: Any] = [
                    "fullName": fullName,
                    "personalSecurityNumber": personalNumber,
                    "email": email,
                    "companyCode": companyCode,
                    "admin": false
                ]
                
                ref.child("users").child(personalNumber).setValue(userData)
                completion(true, nil)
            }
            
        }
        
    }
}
