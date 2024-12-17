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
}
