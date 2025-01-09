//
//  EmployeeDetailView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-02.
//

import SwiftUI

struct EmployeeDetailView: View {
    
    var employee: EmployeeData
  
    var body: some View {
        
        Text(employee.fullName)
        Text("Email: \(employee.email)")
        Text(employee.personalNumber)
        Text("Role: \(employee.isAdmin ? "Admin" : "Employee")")
    }
}

#Preview {
    EmployeeDetailView(employee: EmployeeData(id: "1", data: [
        "fullName": "John Doe",
        "email": "john.doe@example.com",
        "personalSecurityNumber": "12345",
        "companyCode": "AB123",
        "admin": true
    ]))
}
