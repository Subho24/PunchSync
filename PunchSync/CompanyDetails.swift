//
//  CompanyDetails.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2025-01-09.
//

import SwiftUI

// Modeli për të mbajtur të dhënat e kompanisë
class CompanyDetails: ObservableObject {
    @Published var companyName: String = ""
    @Published var orgNumber: String = ""
    @Published var companyCode: String = ""
}

