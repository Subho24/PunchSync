//
//  PendingUsersView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2025-01-25.
//

import SwiftUI

struct PendingUsersView: View {
    
    let pendingUsers: [String: Any]
    let handleVerification: (String, Bool) -> Void
    
    var body: some View {
        
        Section(header: Text("Pending Users")) {
            ForEach(Array(pendingUsers.keys), id: \.self) { personalNumber in
                if let userData = pendingUsers[personalNumber] as? [String: Any],
                   let fullName = userData["fullName"] as? String {
                    VStack {
                        Text(fullName)
                            .padding(.bottom, 20)
                        HStack {
                            Button("Verify") {
                                handleVerification(personalNumber, true)
                            }
                            .padding(8)
                            .padding(.horizontal, 15)
                            .background(Color.green)
                            .cornerRadius(10)
                            .foregroundStyle(.white)
                            
                            Button("Deny") {
                                handleVerification(personalNumber, false)
                            }
                            .padding(8)
                            .padding(.horizontal, 15)
                            .background(Color.red)
                            .cornerRadius(10)
                            .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                }
            }
        }
    }
}

// Preview with mock data and a mock handleVerification closure
struct PendingUsersView_Previews: PreviewProvider {
    static var previews: some View {
        PendingUsersView(
            pendingUsers: ["12345": ["fullName": "John Doe"], "67890": ["fullName": "Jane Smith"]],
            handleVerification: { personalNumber, approved in
                print("Verified \(personalNumber): \(approved ? "Approved" : "Denied")")
            }
        )
    }
}

