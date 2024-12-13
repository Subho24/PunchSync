//
//  ContentView.swift
//  PunchSync
//
//  Created by Subhojit Saha on 2024-12-13.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "lightbulb")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello guys!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
