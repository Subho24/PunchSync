//
//  ContentView.swift
//  PunchSync
//
//  Created by Subhojit Saha on 2024-12-03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      
        TabView {
            Tab("Dashboard", systemImage: ""){
                Text("Hej Admin")
            }
            Tab("Check In / Out", systemImage: ""){
                Text("Hej User")
            }
            Tab("More", systemImage: ""){
                Text("More as Admin")
            }
        }
    }
}

#Preview {
    ContentView()
}
 
