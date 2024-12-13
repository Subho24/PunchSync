//
//  UnloggedView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI

struct UnloggedView: View {
    var body: some View {
        
        VStack {
            Text("PunchSync")
                .font(.largeTitle)
                .padding()
            Text("Login")
                .padding()
            Text("Sign Up as Company")
                .padding()
            Text("Sign Up as Employee")
        }
    }
}

#Preview {
    UnloggedView()
}
