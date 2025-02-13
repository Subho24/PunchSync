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
    */
    
    func saveUserData(fullName: String, personalNumber: String, email: String, password: String, companyCode: String, completion: @escaping (Bool, String?) -> Void) {
        let ref = Database.database().reference()

        // Validate company code
        validateCompanyCode(companyCode: companyCode) { isValid, error in
            if let error = error {
                completion(false, error)
                return
            }

            guard isValid else {
                completion(false, "Invalid company code")
                return
            }

            // Check if personal number is already registered for the company
            ref.child("users").observeSingleEvent(of: .value) { snapshot in
                if let users = snapshot.value as? [String: [String: Any]] {
                    for (_, userData) in users {
                        if let registeredCompanyCode = userData["companyCode"] as? String,
                           let registeredPersonalNumber = userData["personalSecurityNumber"] as? String,
                           registeredCompanyCode == companyCode,
                           registeredPersonalNumber == personalNumber {
                            completion(false, "Personal number already registered for this company.")
                            return
                        }
                    }
                }

                // Create new user in Firebase Authentication
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        completion(false, error.localizedDescription)
                        return
                    }

                    guard let user = authResult?.user else {
                        completion(false, "Failed to create user")
                        return
                    }

                    // Store employee data in Realtime Database
                    let userData: [String: Any] = [
                        "fullName": fullName,
                        "personalSecurityNumber": personalNumber,
                        "email": email,
                        "companyCode": companyCode,
                        "admin": false,
                        "pending": true
                    ]

                    ref.child("users").child(user.uid).setValue(userData) { error, _ in
                        if let error = error {
                            // Delete the user from Auth if DB write fails
                            user.delete { _ in }
                            completion(false, error.localizedDescription)
                        } else {
                            completion(true, nil)
                        }
                    }
                }
            }
        }
    }

    
    func removeUser(userId: String, completion: @escaping (Bool, String?) -> Void) {
        
        let ref = Database.database().reference()
        
        ref.child("users").child(userId).removeValue { error, _ in
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
            .observeSingleEvent(of: .value) { snapshot in
                print("Snapshot data: \(snapshot.value ?? "No data")")
                var pendingUsers: [String: Any] = [:]
                
                for child in snapshot.children {
                    guard let snapshot = child as? DataSnapshot,
                          let userData = snapshot.value as? [String: Any],
                          let userCompanyCode = userData["companyCode"] as? String,
                          let pending = userData["pending"] as? Bool,
                          userCompanyCode == companyCode,
                          pending == true
                    else {
                        continue
                    }
                    
                    pendingUsers[snapshot.key] = userData
                }
                completion(pendingUsers, nil)
            } withCancel: { error in
                // Hantera fel
                completion(nil, error.localizedDescription)
            }
    }
    
    func verifyUser(userId: String, approved: Bool, completion: @escaping (Bool, String?) -> Void) {
        let ref = Database.database().reference()
        
        // Hämta användaren direkt baserat på userId
        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(),
                  let userData = snapshot.value as? [String: Any],
                  let pending = userData["pending"] as? Bool,
                  pending == true else {
                completion(false, "User not found or already verified")
                return
            }
            
            if approved {
                // Uppdatera användarens status till verifierad
                ref.child("users").child(userId).child("pending").setValue(false) { error, _ in
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        completion(true, nil)
                    }
                }
            } else {
                // Ta bort användaren om den inte godkänns
                ref.child("users").child(userId).removeValue { error, _ in
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
        
        // Query users to check for existing personal number within the same company
        databaseRef.child("users").observeSingleEvent(of: .value) { snapshot, _ in
            if let users = snapshot.value as? [String: [String: Any]] {
                for (_, userData) in users {
                    if let registeredCompanyCode = userData["companyCode"] as? String,
                       let registeredPersonalNumber = userData["personalSecurityNumber"] as? String,
                       registeredCompanyCode == yourcompanyID,
                       registeredPersonalNumber == personalNumber {
                        completion("Personal number already registered for this company.")
                        return
                    }
                }
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
            
            // Query users to check for existing personal number within the same company
            databaseRef.child("users").observeSingleEvent(of: .value) { snapshot, _ in
                if let users = snapshot.value as? [String: [String: Any]] {
                    for (_, userData) in users {
                        if let registeredCompanyCode = userData["companyCode"] as? String,
                           let registeredPersonalNumber = userData["personalSecurityNumber"] as? String,
                           registeredCompanyCode == yourcompanyID,
                           registeredPersonalNumber == personalNumber {
                            completion("Personal number already registered for this company.")
                            return
                        }
                    }
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
        var allEmployees: [EmployeeData] = []
        let group = DispatchGroup()
        
        // First, load admins (stored with auth UIDs)
        group.enter()
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            if let usersDict = snapshot.value as? [String: [String: Any]] {
                // Filter for admins with matching company code
                let admins = usersDict.compactMap { (uid, userData) -> EmployeeData? in
                    guard let userCompanyCode = userData["companyCode"] as? String,
                          let isAdmin = userData["admin"] as? Bool,
                          userCompanyCode == companyCode,
                          isAdmin == true else {
                        return nil
                    }
                    return EmployeeData(id: uid, data: userData)
                }
                allEmployees.append(contentsOf: admins)
            }
            group.leave()
        }
        
        // Then, load regular employees (stored under company code)
        group.enter()
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            if let usersDict = snapshot.value as? [String: [String: Any]] {
                // Filter out pending users
                let employees = usersDict.compactMap { (personalNumber, userData) -> EmployeeData? in
                    guard let isPending = userData["pending"] as? Bool,
                          !isPending,
                          let isAdmin = userData["admin"] as? Bool,
                          !isAdmin else {
                        return nil
                    }
                    return EmployeeData(id: personalNumber, data: userData)
                }
                allEmployees.append(contentsOf: employees)
            }
            group.leave()
        }
        
        // When both loads are complete, return all employees
        group.notify(queue: .main) {
            completion(allEmployees, nil)
        }
    }
    
    
    func loadEmployeeData(employeeData: EmployeeData, completion: @escaping (Bool, Error?) -> Void) {
        let ref = Database.database().reference()
        
        // Kontrollera om användaren är inloggad
        guard let currentUser = Auth.auth().currentUser else {
            completion(false, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in"]))
            return
        }
        
        let currentUID = currentUser.uid
        
        // Hämta användardata från Firebase
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let usersDict = snapshot.value as? [String: Any] else {
                completion(false, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "No users found in the database"]))
                return
            }
            
            // Debugging: skriv ut alla användare för att verifiera om currentUID finns
            print("Users found in database: \(usersDict)")
            
            // Första sökningen: Kontrollera om användardata finns under currentUID
            if let userData = usersDict[currentUID] as? [String: Any] {
                // Hitta användaren med UID
                employeeData.fullName = userData["fullName"] as? String ?? "Unknown Employee"
                employeeData.companyCode = userData["companyCode"] as? String ?? "Unknown Company Code"
                employeeData.email = userData["email"] as? String ?? ""
                employeeData.personalNumber = userData["personalSecurityNumber"] as? String ?? ""
                employeeData.isAdmin = userData["admin"] as? Bool ?? false
                employeeData.pending = userData["pending"] as? Bool ?? false
                completion(true, nil)
            } else {
                // Debugging: skriv ut vad som händer om användaren inte hittas med UID
                print("User with UID \(currentUID) not found. Checking companyCode...")
                
                // Andra sökningen: Kontrollera om användardata finns under companyCode och personalNumber
                let companyCode = employeeData.companyCode
                let personalNumber = employeeData.personalNumber
                ref.child("users").child(companyCode).child(personalNumber).observeSingleEvent(of: .value) { snapshot, _ in
                    guard let employeeDetails = snapshot.value as? [String: Any] else {
                        completion(false, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Employee data not found"]))
                        return
                    }

                    employeeData.fullName = employeeDetails["fullName"] as? String ?? "Unknown Employee"
                    employeeData.companyCode = companyCode
                    employeeData.email = employeeDetails["email"] as? String ?? ""
                    employeeData.personalNumber = personalNumber
                    employeeData.isAdmin = employeeDetails["admin"] as? Bool ?? false
                    employeeData.pending = employeeDetails["pending"] as? Bool ?? false

                    completion(true, nil)
                }
            }
        }
    }

    func saveLeaveRequest(title: String, requestType: String, description: String, startDate: Date, endDate: Date, employeeName: String, completion: @escaping (Bool, String?) -> Void) {
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
        
        // Get today's start of day for comparison
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if dates have been modified from their initial values
        let initialStartDate = calendar.startOfDay(for: Date())
        let initialEndDate = calendar.startOfDay(for: calendar.date(byAdding: .month, value: 1, to: Date())!)
        
        let selectedStartDate = calendar.startOfDay(for: startDate)
        let selectedEndDate = calendar.startOfDay(for: endDate)
        
        if selectedStartDate == initialStartDate || selectedEndDate == initialEndDate {
            completion(false, "Please select start and end dates")
            return
        }
        
        // Validate start date is not in the past
        guard selectedStartDate >= today else {
            completion(false, "Start date cannot be in the past")
            return
        }
        
        // Validate end date is after start date
        guard selectedEndDate >= selectedStartDate else {
            completion(false, "End date must be after start date")
            return
        }

        let ref = Database.database().reference()

        // Förutsatt att användaren har companyCode sparat i sin profil
        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any],
                  let companyCode = userData["companyCode"] as? String else {
                completion(false, "Company code not found for user")
                return
            }

            // Skapa request data, utan att behöva inkludera companyCode i själva datan
            let requestData: [String: Any] = [
                "title": title,
                "requestType": requestType,
                "description": description,
                "startDate": startDate.timeIntervalSince1970,
                "endDate": endDate.timeIntervalSince1970,
                "timestamp": ServerValue.timestamp(),
                "employeeName": employeeName,
                "userId": userId
            ]
            
            // Spara under companyCode
            ref.child("leaveRequests")
                .child(companyCode) // Gruppera under companyCode
                .childByAutoId() // Generera ett unikt ID för varje leave request
                .setValue(requestData) { error, _ in
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        completion(true, nil)
                    }
                }
        }
    }

    func loadLeaveRequests(forCompanyCode companyCode: String, completion: @escaping ([LeaveRequest]?, String?) -> Void) {
        let ref = Database.database().reference()
        
        // Ladda alla leave requests för ett specifikt companyCode
        ref.child("leaveRequests").child(companyCode).observeSingleEvent(of: .value) { snapshot in
            var leaveRequests: [LeaveRequest] = []

            // Kontrollera om det finns data
            guard let snapshotValue = snapshot.value as? [String: Any] else {
                completion([], nil) // Ingen data, returnera en tom lista
                return
            }

            for (key, value) in snapshotValue {
                if let requestData = value as? [String: Any],
                   let title = requestData["title"] as? String,
                   let requestType = requestData["requestType"] as? String,
                   let description = requestData["description"] as? String,
                   let startDateInterval = requestData["startDate"] as? TimeInterval,
                   let endDateInterval = requestData["endDate"] as? TimeInterval,
                   let employeeName = requestData["employeeName"] as? String {

                    let startDate = Date(timeIntervalSince1970: startDateInterval)
                    let endDate = Date(timeIntervalSince1970: endDateInterval)

                    let leaveRequest = LeaveRequest(
                        id: key,
                        title: title,
                        requestType: requestType,
                        description: description,
                        startDate: startDate,
                        endDate: endDate,
                        employeeName: employeeName
                    )

                    leaveRequests.append(leaveRequest)
                }
            }

            completion(leaveRequests, nil) // Returnera listan av requests för det angivna companyCode
        }
    }

}
