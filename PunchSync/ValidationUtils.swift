//
//  ValidationUtils.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-17.
//

import Foundation

struct ValidationUtils {
    
    static func formatOrgNumber(_ input: String) -> String {
        // Ta bort alla icke-siffror
        let digitsOnly = input.filter { $0.isNumber }

        // Formatera som "xxxxxx-xxxx"
        if digitsOnly.count > 6 {
            let prefix = String(digitsOnly.prefix(6))
            let suffix = String(digitsOnly.suffix(from: digitsOnly.index(digitsOnly.startIndex, offsetBy: 6)))
            return "\(prefix)-\(suffix.prefix(4))"
        }
        return digitsOnly
    }
    
    static func validatesignUpAsCompany(companyName: String, orgNumber: String) -> String? {
        if companyName.isEmpty {
            return "Company name is required."
        } else if orgNumber.isEmpty {
            return "Organisation number is required."
        }
        return nil
    }
    
    // Validate email format
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // Validate password strength (e.g., minimum 6 characters)
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    
    // Check if a field is empty
    static func isNotEmpty(_ text: String) -> Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // General input validation for forms
    static func validateRegisterInputs(fullName: String, email: String, password: String, confirmPassword: String, companyCode: String, personalNumber: String? = nil) -> String? {
        if !isNotEmpty(fullName) {
            return "Name is required"
        } else if !isNotEmpty(email) {
            return "Email is required."
        } else if !isValidEmail(email) {
            return "Invalid email format."
        } else if !isValidPassword(password) {
            return "Password must be at least 6 characters."
        } else if password != confirmPassword {
            return "Passwords do not match."
        } else if !isNotEmpty(companyCode) {
            return "Company code is required."
        }
        
        if let personalNumber = personalNumber {
            if !isNotEmpty(personalNumber) {
                return "Personal number is required."
            }
        }
        return nil
    }
}

