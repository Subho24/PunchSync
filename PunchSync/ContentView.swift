//
//  ContentView.swift
//  PunchSync
//
//  Created by Subhojit Saha on 2024-12-03.
//

import SwiftUI
import Firebase


struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, katya och arlinda")
        }
        .padding()
        .onAppear {
            fbFunc()
        }
    }
    
    func fbFunc() {
        var ref: DatabaseReference!

        ref = Database.database().reference()
        ref.child("punchSyncDatabase")
    }
}

#Preview {
    ContentView()
}
