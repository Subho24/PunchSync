//
//  EmployeeData.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-27.
//

import Foundation

class EmployeeData: Identifiable, ObservableObject {
    let id: String  // This will be the personal number
    @Published var fullName: String
    @Published var email: String
    @Published var personalNumber: String
    @Published var companyCode: String
    @Published var isAdmin: Bool
    @Published var pending: Bool
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.fullName = data["fullName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.personalNumber = data["personalSecurityNumber"] as? String ?? ""
        self.companyCode = data["companyCode"] as? String ?? ""
        self.isAdmin = data["admin"] as? Bool ?? false
        self.pending = data["pending"] as? Bool ?? false
    }
}
