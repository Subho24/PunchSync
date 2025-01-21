//
//  LeaveRequestModel.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-18.
//

import Foundation

struct LeaveRequest: Identifiable {
    var id: String
    var title: String
    var requestType: String
    var description: String
    var startDate: Date
    var endDate: Date
}

extension LeaveRequest {
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "requestType": requestType,
            "description": description,
            "startDate": startDate.timeIntervalSince1970,
            "endDate": endDate.timeIntervalSince1970
        ]
    }
}
