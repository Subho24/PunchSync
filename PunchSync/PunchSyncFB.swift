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
    var adminData = AdminData()
    
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
    
    func forgotPassword(email : String, completion: @escaping (String?) -> Void) {
       Task {
           do {
               try await Auth.auth().sendPasswordReset(withEmail: email)
               print("Sent!")
               completion(nil)
           } catch {
               print("Reset failed: \(error.localizedDescription)")
               completion(error.localizedDescription)
           }
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
    
    /*
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
                        "admin": false,
                        "pending": true
                    ]
                    
                    ref.child("users").child(personalNumber).setValue(userData)
                    completion(true, nil)
                }
                
            }
        }
    }
     */
    
    func saveUserData(fullName: String, personalNumber: String, email: String, companyCode: String, completion: @escaping (Bool, String?) -> Void) {
        let ref = Database.database().reference()

        // Validera företagets kod
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
            ref.child("users").child(companyCode).child(personalNumber).observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    // Personnummer redan registrerat under detta företag
                    completion(false, "Personal number already registered for this company.")
                } else {
                    // Registrera användaren under företaget
                    let userData: [String: Any] = [
                        "fullName": fullName,
                        "personalSecurityNumber": personalNumber,
                        "email": email,
                        "companyCode": companyCode,
                        "admin": false,
                        "pending": true
                    ]
                    
                    ref.child("users").child(companyCode).child(personalNumber).setValue(userData) { error, _ in
                        if let error = error {
                            completion(false, error.localizedDescription)
                        } else {
                            completion(true, nil)
                        }
                    }
                }
            }
        }
    }
    
    func removeUser(personalNumber: String, completion: @escaping (Bool, String?) -> Void) {
        
        let ref = Database.database().reference()
        
        ref.child("users").child(personalNumber).removeValue { error, _ in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // Function to get pending users for a specific company
    func getPendingUsers(companyCode: String, completion: @escaping ([String: Any]?, String?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("users")
            .queryOrdered(byChild: "companyCode")
            .queryEqual(toValue: companyCode)
            .observeSingleEvent(of: .value) { snapshot in
                print("Snapshot data: \(snapshot.value ?? "No data")")
                var pendingUsers: [String: Any] = [:]
                
                for child in snapshot.children {
                    guard let snapshot = child as? DataSnapshot,
                          let userData = snapshot.value as? [String: Any],
                          let pending = userData["pending"] as? Bool,
                          pending == true else {
                        continue
                    }
                    
                    pendingUsers[snapshot.key] = userData
                }
                
                completion(pendingUsers, nil)
        }
    }
    
    func verifyUser(personalNumber: String, approved: Bool, completion: @escaping (Bool, String?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("users").child(personalNumber).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let userData = snapshot.value as? [String: Any],
                  let pending = userData["pending"] as? Bool,
                  pending == true else {
                completion(false, "User not found or already verified")
                return
            }
            
            if approved {
                ref.child("users").child(personalNumber).child("pending").setValue(false) { error, _ in
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        completion(true, nil)
                    }
                }
            } else {
                ref.child("users").child(personalNumber).removeValue { error, _ in
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }
    
    func createProfile(email: String, password: String, fullName: String, personalNumber: String, yourcompanyID: String, completion: @escaping (String?) -> Void) {
        // Step 1: Check if personal number already exists anywhere in the database
        let databaseRef = Database.database().reference()
        
        // Query users by personal number
        databaseRef.child("users").queryOrdered(byChild: "personalSecurityNumber").queryEqual(toValue: personalNumber).observeSingleEvent(of: .value) { snapshot, _ in
            if snapshot.exists() && snapshot.childrenCount > 0 {
                completion("Personal number already registered")
                return
            }
            
            // Step 2: If personal number is unique, create the new user
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
                
                // Step 3: Add the new user's details to Realtime Database
                let userDetails: [String: Any] = [
                    "fullName": fullName,
                    "personalSecurityNumber": personalNumber,
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
    }
    
    func createNewAdmin(email: String, password: String, fullName: String, personalNumber: String, yourcompanyID: String, currentAdmin: User, adminPassword: String, completion: @escaping (String?) -> Void) {
        let currentAdminUID = currentAdmin.uid
        let currentAdminEmail = currentAdmin.email ?? ""
        
        // First verify the current admin's password
        let credential = EmailAuthProvider.credential(withEmail: currentAdminEmail, password: adminPassword)
        
        currentAdmin.reauthenticate(with: credential) { _, error in
            if let error = error {
                // Password verification failed
                completion("Current admin password is incorrect")
                return
            }
            
            let databaseRef = Database.database().reference()
            
            // Query users by personal number
            databaseRef.child("users").queryOrdered(byChild: "personalSecurityNumber").queryEqual(toValue: personalNumber).observeSingleEvent(of: .value) { snapshot, _ in
                if snapshot.exists() && snapshot.childrenCount > 0 {
                    completion("Personal number already registered")
                    return
                }
                
                // Password verified, proceed with creating new admin
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
                            "personalSecurityNumber": personalNumber,
                            "email": email,
                            "companyCode": yourcompanyID,
                            "admin": true,
                            "createdBy": currentAdminUID,
                            "createdAt": ServerValue.timestamp()
                        ]
                        
                        databaseRef.child("users").child(newUser.uid).setValue(userDetails) { error, _ in
                            if let error = error {
                                print("Error adding user to database: \(error.localizedDescription)")
                                
                                // If database update fails, delete the created auth user
                                newUser.delete { error in
                                    if let error = error {
                                        print("Error deleting auth user after database failure: \(error.localizedDescription)")
                                    }
                                }
                                
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
    
    func loadEmployeeData(employeeData: EmployeeData, completion: @escaping (Bool, Error?) -> Void) {
        let ref = Database.database().reference()
        
        // Kontrollera att en användare är inloggad
        guard let currentUser = Auth.auth().currentUser else {
            completion(false, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in"]))
            return
        }
        
        let userId = currentUser.uid
        
        // Hämta data från databasen för den inloggade användaren
        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                completion(false, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Employee data not found"]))
                return
            }
            
            // Extrahera data och tilldela det till EmployeeData-objektet
            employeeData.fullName = data["fullName"] as? String ?? "Unknown Employee"
            employeeData.companyCode = data["companyCode"] as? String ?? "Unknown Company Code"
            employeeData.email = data["email"] as? String ?? ""
            employeeData.personalNumber = data["personalSecurityNumber"] as? String ?? ""
            employeeData.isAdmin = data["admin"] as? Bool ?? false
            employeeData.pending = data["pending"] as? Bool ?? false
            
            completion(true, nil)
        }
    }

    func saveLeaveRequest(title: String, requestType: String, description: String, startDate: Date, endDate: Date, completion: @escaping (Bool, String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "No user is currently logged in")
            return
        }
        
        // Validate input
        guard !title.isEmpty else {
            completion(false, "Title is required")
            return
        }
        
        guard !requestType.isEmpty else {
            completion(false, "Request type is required")
            return
        }
        
        let ref = Database.database().reference()
        
        let requestData: [String: Any] = [
            "title": title,
            "requestType": requestType,
            "description": description,
            "startDate": startDate.timeIntervalSince1970,
            "endDate": endDate.timeIntervalSince1970,
            "timestamp": ServerValue.timestamp()
        ]
        
        ref.child("leaveRequests")
            .child(userId)
            .childByAutoId()
            .setValue(requestData) { error, _ in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
    }

}
