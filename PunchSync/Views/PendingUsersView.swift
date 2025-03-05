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
                    VStack(alignment: .leading, spacing: 12) {
                                            Text("Name: \(fullName)")
                                                .font(.headline)
                                                .foregroundColor(.black)
                        HStack {
                            Button("Verify") {
                                handleVerification(personalNumber, true)
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "8BC5A3"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.green.opacity(0.5), radius: 4, x: 0, y: 2)
                            
                            Button("Deny") {
                                handleVerification(personalNumber, false)
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "C96D59"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: Color.red.opacity(0.5), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
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

