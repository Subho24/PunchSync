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
    
    func saveOrDeleteCompanyData(
        companyName: String? = nil,
        orgNumber: String,
        delete: Bool = false,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let ref = Database.database().reference()
        
        if delete {
            // Om flaggan för borttagning är sann, radera företaget
            ref.child("companies").child(orgNumber).removeValue { error, _ in
                if let error = error {
                    completion(false, "Failed to delete company data: \(error.localizedDescription)")
                } else {
                    completion(true, nil) // Lyckades radera
                }
            }
        } else {
            // Om det är en sparningsoperation, kontrollera först om orgNumber redan finns
            ref.child("companies").child(orgNumber).observeSingleEvent(of: .value) { [self] snapshot in
                if snapshot.exists() {
                    completion(false, "This organization number is already registered.") // Företaget existerar
                } else {
                    // Generera companyCode och spara företaget
                    let newCompanyCode = generateCompanyCode()
                    self.companyCode = newCompanyCode
                    
                    let companyData: [String: Any] = [
                        "companyName": companyName ?? "",
                        "organizationNumber": orgNumber,
                        "companyCode": newCompanyCode
                    ]
                    
                    ref.child("companies").child(orgNumber).setValue(companyData) { error, _ in
                        if let error = error {
                            completion(false, "Failed to save company data: \(error.localizedDescription)")
                        } else {
                            completion(true, nil) // Lyckades spara
                        }
                    }
                }
            }
        }
    }

    private func generateCompanyCode() -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<10).map { _ in characters.randomElement()! })
    }

    
    func deleteCompanyData(orgNumber: String, completion: @escaping (Bool, String?) -> Void) {
        let ref = Database.database().reference()
        
        // Remove from database
        ref.child("companies").child(orgNumber).removeValue { error, _ in
            if let error = error {
                completion(false, "Failed to delete company data: \(error.localizedDescription)")
                return
            }
            
            completion(true, nil) // Successfully deleted
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
        
        validateCompanyCode(companyCode: companyCode) { isValid, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard isValid else {
                completion(false, "Invalid company code")
                return
            }
            
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
    
    func createNewAdmin(email: String, password: String, fullName: String, yourcompanyID: String, currentAdmin: User, adminPassword: String, completion: @escaping (String?) -> Void) {
        let currentAdminUID = currentAdmin.uid
        let currentAdminEmail = currentAdmin.email ?? ""
        
        let databaseRef = Database.database().reference()
        databaseRef.child("users").child(currentAdminUID).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any],
                  let isAdmin = userData["admin"] as? Bool,
                  isAdmin else {
                completion("Current user is not authorized to create admins")
                return
            }
            
            // Store current admin's credentials
            let originalAdminEmail = Auth.auth().currentUser?.email ?? ""
            
            // Create new admin
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
                
                let userDetails: [String: Any] = [
                    "fullName": fullName,
                    "email": email,
                    "companyCode": yourcompanyID,
                    "admin": true,
                    "createdBy": currentAdminUID,
                    "createdAt": ServerValue.timestamp()
                ]
                
                databaseRef.child("users").child(newUser.uid).setValue(userDetails) { error, _ in
                    if let error = error {
                        print("Error adding user to database: \(error.localizedDescription)")
                        completion(error.localizedDescription)
                        return
                    }
                    
                    print("New admin added to Realtime Database successfully!")
                    
                    // Now sign back in as the original admin
                    Auth.auth().signIn(withEmail: originalAdminEmail, password: adminPassword) { authResult, error in
                        if let error = error {
                            print("Error signing back in as original admin: \(error.localizedDescription)")
                            completion("New admin created but failed to restore original admin session. Please sign out and back in.")
                        } else {
                            print("Successfully restored original admin session")
                            completion(nil)
                        }
                    }
                }
            }
        }
    }

    
    func loadAdminData(adminData: AdminData, completion: @escaping (Bool, Error?) -> Void) {
        let ref = Database.database().reference()
        
        guard let currentUser = Auth.auth().currentUser else {
            completion(false, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in"]))
            return
        }
        
        let userId = currentUser.uid
        
        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                completion(false, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Admin data not found"]))
                return
            }
            
            adminData.fullName = data["fullName"] as? String ?? "Unknown Admin"
            adminData.companyCode = data["companyCode"] as? String ?? "Unknown Company Code"
            
            completion(true, nil)
        }
    }
    
    func validateCompanyCode(companyCode: String, completion: @escaping (Bool, String?) -> Void) {
        let databaseRef = Database.database().reference()
        
        // Check users node for any existing user with this company code
        databaseRef.child("users").queryOrdered(byChild: "companyCode")
            .queryEqual(toValue: companyCode)
            .observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    // Company code exists in database
                    completion(true, nil)
                } else {
                    // Company code not found
                    completion(false, "Invalid company code. Please check with your administrator.")
                }
            } withCancel: { error in
                completion(false, "Error validating company code: \(error.localizedDescription)")
            }
    }
    
    
    func loadEmployees(for companyCode: String, completion: @escaping ([EmployeeData]?, Error?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let usersDict = snapshot.value as? [String: [String: Any]] else {
                completion(nil, NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch users"]))
                return
            }
            
            // Filtrera ut anställda som tillhör samma companyCode
            let employees = usersDict.compactMap { (key, value) -> EmployeeData? in
                guard let userCompanyCode = value["companyCode"] as? String,
                      userCompanyCode == companyCode else { return nil }
                return EmployeeData(id: key, data: value)
            }
            
            completion(employees, nil)
        }
    }

}
