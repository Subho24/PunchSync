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
    
    static func isValidOrgNumber(_ orgNumber: String) -> Bool {
 
        let digitsOnly = orgNumber.filter { $0.isNumber }
        guard digitsOnly.count == 10 else {
            return false
        }
        
        guard let firstDigit = digitsOnly.first?.wholeNumberValue, (2...9).contains(firstDigit) else {
            return false
        }
        
        // Validera med Luhn-algoritmen
        return isValidLuhn(digitsOnly)
    }
    
    static func formatPersonalNumber(_ input: String) -> String {
        // Ta bort alla icke-siffror
        let digitsOnly = input.filter { $0.isNumber }

        // Formatera som "xxxxxxxx-xxxx"
        if digitsOnly.count > 8 {
            let prefix = String(digitsOnly.prefix(8))
            let suffix = String(digitsOnly.suffix(from: digitsOnly.index(digitsOnly.startIndex, offsetBy: 8)))
            return "\(prefix)-\(suffix.prefix(4))"
        }
        return digitsOnly
    }
    
    static func isValidPersonalNumber(_ personalNumber: String) -> Bool {
      
        let digitsOnly = personalNumber.filter { $0.isNumber }
            
        guard digitsOnly.count == 10 || digitsOnly.count == 12 else {
            return false
        }
            
        // Om 12 siffror, ignorera de första två (för århundrade)
        let trimmed = digitsOnly.count == 12 ? String(digitsOnly.suffix(10)) : digitsOnly
            
        let datePart = String(trimmed.prefix(6)) // YYYYMM eller YYMMDD
        _ = String(trimmed.suffix(4)) // -XXXX
            
        // Validera datumet
        guard isValidDate(datePart: datePart) else {
            return false
        }
            
        return isValidLuhn(trimmed)
    }
        
    // Validate the date
    private static func isValidDate(datePart: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        dateFormatter.locale = Locale(identifier: "sv_SE")
        return dateFormatter.date(from: datePart) != nil
    }
    
    // Luhn algorithm
    private static func isValidLuhn(_ input: String) -> Bool {
        let digits = input.compactMap { $0.wholeNumberValue }
        guard digits.count == 10 else { return false }
        
        var sum = 0
        for (index, digit) in digits.enumerated() {
            let isOdd = index % 2 == 0
            let multiplied = isOdd ? digit * 2 : digit
            sum += multiplied > 9 ? multiplied - 9 : multiplied
        }
        
        return sum % 10 == 0
    }
    
    static func validatesignUpAsCompany(companyName: String, orgNumber: String) -> String? {
        if companyName.isEmpty {
            return "Company name is required."
        } else if orgNumber.isEmpty {
            return "Organization number is required."
        } else if orgNumber.count < 11 {
            return "Organization number should contain 10 numbers"
        } else if !isValidOrgNumber(orgNumber) {
            return "Organization number is invalid."
        }
        return nil
    }
    
    static func validateCompanyName(companyName: String) -> String? {
        if companyName.isEmpty {
            return "Company name is required."
        }
        return nil
    }
    
    static func validateOrgNumber(orgNumber: String) -> String? {
        if orgNumber.isEmpty {
            return "Organization number is required."
        } else if orgNumber.count < 11 {
            return "Organization number should contain 10 numbers"
        } else if !isValidOrgNumber(orgNumber) {
            return "Organization number is invalid."
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
            } else if !isValidPersonalNumber(personalNumber) {
                return "Invalid personal number format."
            }
        }
        return nil
    }
    
    static func validateEmail(email: String) -> String? {
        if !isNotEmpty(email) {
            return "Email is required."
        } else if !isValidEmail(email) {
            return "Invalid email format."
        }
        return nil
    }
    
    static func validatePassword(password: String) -> String? {
        if !isNotEmpty(password) {
            return "Password is required."
        } else if !isValidPassword(password) {
            return "Please enter at least 6 characters."
        }
        return nil
    }
    
    static func validateConfirmPassword(password: String, confirmPassword: String) -> String? {
        if !isNotEmpty(confirmPassword) {
            return "Password confirmation is required."
        } else if password != confirmPassword {
            return "Passwords do not match."
        }
        return nil
    }
    
    static func validateName(name: String) -> String? {
        if !isNotEmpty(name) {
            return "Name is required."
        }
        return nil
    }
    
    static func validateCompanyCode(companyCode: String) -> String? {
        if !isNotEmpty(companyCode) {
            return "Company code field is required."
        }
        return nil
    }
    
    static func validatePersonalNumber (personalNumber: String) -> String? {
        if !isNotEmpty(personalNumber) {
            return "Personal number field cannot be empty."
        } else if !isValidPersonalNumber(personalNumber) {
            return "Invalid personal number format."
        }
        return nil
    }
    
    static func validateReset(email: String) -> String? {
        if !isNotEmpty(email) {
            return "Email field cannot be empty."
        } else if !isValidEmail(email) {
            return "Invalid email format."
        }
        return nil
    }
}

