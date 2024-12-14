//
//  ContentView.swift
//  PunchSync
//
//  Created by Subhojit Saha on 2024-12-13.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @State var isLoggedIn: Bool?
    
    var body: some View {
        
        VStack {
            if isLoggedIn == true {
                HomeView()
            }
            if isLoggedIn == false {
                UnloggedView()
            }
        }
        .onAppear() {
            Auth.auth().addStateDidChangeListener { auth, user in
                print("USER CHANGE")
                
                if Auth.auth().currentUser == nil {
                    isLoggedIn = false
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
