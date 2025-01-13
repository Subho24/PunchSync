//
//  AdminData.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-27.
//

import Foundation

class AdminData: ObservableObject {
    @Published var fullName: String = ""
    @Published var companyCode: String = ""
}
