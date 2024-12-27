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
    
    var companyCode: String = "" 
    
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
    
    func saveCompanyData(companyName: String, orgNumber: String, completion: @escaping (Bool, String?) -> Void) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        func generateCompanyCode() -> String {
            let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<10).map { _ in characters.randomElement()! })
        }
        
        // First check if the organization number exists
        ref.child("companies").child(orgNumber).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(false, "This organization number is already registered.") // Company exists, return false
            } else {
                // Organization number doesn't exist, safe to save
                let newCompanyCode = generateCompanyCode()
                self.companyCode = newCompanyCode
                
                let companyData: [String: Any] = [
                    "companyName": companyName,
                    "organizationNumber": orgNumber,
                    "companyCode": newCompanyCode
                ]
                
                ref.child("companies").child(orgNumber).setValue(companyData)
                completion(true, nil) // Successfully saved, return true
            }
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
    
    func createProfile(email: String, password: String, fullName: String, yourcompanyID: String, completion: @escaping (String?) -> Void) {
        // Step 1: Create the new user in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                completion(error.localizedDescription)
                return
            }
            guard let user = authResult?.user else {
                print("User creation failed.")
                completion("User creation failed.")
                return
            }
            print("User created with UID: \(user.uid)")
            
            // Step 2: Add the new user's details to Realtime Database
            let databaseRef = Database.database().reference()
            let userDetails: [String: Any] = [
                "fullName": fullName,
                "email": email,
                "companyCode": yourcompanyID,
                "admin": true
            ]
            databaseRef.child("users").child(user.uid).setValue(userDetails) { error, _ in
                if let error = error {
                    print("Error adding user to database: \(error.localizedDescription)")
                    completion(error.localizedDescription)
                } else {
                    print("User added to Realtime Database successfully!")
                    completion(nil)
                }
            }
        }
    }
    
    func createNewAdmin(email: String, password: String, fullName: String, yourcompanyID: String,currentAdmin: User, completion: @escaping (String?) -> Void
    ) {
        // Current admin UID is non-optional in User object
        let currentAdminUID = currentAdmin.uid
        
        // First, verify the current user is actually an admin
        let databaseRef = Database.database().reference()
        databaseRef.child("users").child(currentAdminUID).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any],
                  let isAdmin = userData["admin"] as? Bool,
                  isAdmin else {
                completion("Current user is not authorized to create admins")
                return
            }
            
            // Create new admin account using Admin SDK
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Error creating user: \(error.localizedDescription)")
                    completion(error.localizedDescription)
                    return
                }
                
                guard let newUser = authResult?.user else {
                    completion("User creation failed")
                    return
                }
                
                // Add the new admin details to Realtime Database
                let userDetails: [String: Any] = [
                    "fullName": fullName,
                    "email": email,
                    "companyCode": yourcompanyID,
                    "admin": true,
                    "createdBy": currentAdminUID,
                ]
                
                databaseRef.child("users").child(newUser.uid).setValue(userDetails) { error, _ in
                    if let error = error {
                        print("Error adding user to database: \(error.localizedDescription)")
                        completion(error.localizedDescription)
                    } else {
                        print("New admin added to Realtime Database successfully!")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func loadAdminData(adminData: AdminData) async {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is currently logged in")
            return
        }
        
        let userId = currentUser.uid
        let email = currentUser.email ?? "No email found"
        print("Current User ID: \(userId)")
        print("Current User Email: \(email)")
        
        let ref = Database.database().reference()
        
        do {
            let adminSnapshot = try await ref.child("users").child(userId).getData()
            print("Admin Snapshot: \(adminSnapshot.value ?? "No data found")")
            
            guard let adminDataDict = adminSnapshot.value as? [String: Any] else {
                print("Failed to get admin data")
                return
            }
            
            adminData.fullName = adminDataDict["fullName"] as? String ?? "Unknown Admin"
            adminData.companyCode = adminDataDict["companyCode"] as? String ?? "Unknown Company Code"
            
            print("Admin Name: \(adminData.fullName)")
            print("Admin company code: \(adminData.companyCode)")
        } catch {
            print("Error fetching admin data: \(error.localizedDescription)")
        }
    }
}
