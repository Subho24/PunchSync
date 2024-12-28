//
//  EmployeeData.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-27.
//

import Foundation

struct EmployeeData: Identifiable {
    let id: String  // This will be the personal number
    let fullName: String
    let email: String
    let personalNumber: String
    let companyCode: String
    let isAdmin: Bool
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.fullName = data["fullName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.personalNumber = data["personalSecurityNumber"] as? String ?? ""
        self.companyCode = data["companyCode"] as? String ?? ""
        self.isAdmin = data["admin"] as? Bool ?? false
    }
}
