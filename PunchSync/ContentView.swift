//
//  ContentView.swift
//  PunchSync
//
//  Created by Subhojit Saha on 2024-12-13.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct ContentView: View {
    
    @State private var isLoggedIn: Bool?
    @State private var isAdmin: Bool?
    @State private var isLoading: Bool = true 

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if isLoggedIn == true {
                if let isAdmin = isAdmin {
                    HomeView(isAdmin: isAdmin)
                } else {
                    Text("Unable to determine admin status.")
                        .foregroundColor(.red)
                }
            } else if isLoggedIn == false {
                UnloggedView()
            } else {
                Text("Unknown state")
            }
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    isLoggedIn = true
                    fetchAdminStatus(for: user.uid)
                } else {
                    isLoggedIn = false
                    isLoading = false
                }
            }
        }
    }
    
    private func fetchAdminStatus(for userId: String) {
        let ref = Database.database().reference()
        ref.child("users").child(userId).observe(.value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                isAdmin = data["admin"] as? Bool ?? false
            } else {
                print("Admin status not found for user \(userId)")
                isAdmin = false
            }
            isLoading = false
        } withCancel: { error in
            print("Error fetching admin status: \(error.localizedDescription)")
            isAdmin = false
            isLoading = false
        }
    }
}

#Preview {
    ContentView()
}

