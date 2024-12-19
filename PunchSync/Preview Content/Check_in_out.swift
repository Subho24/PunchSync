//
//  Check_in_out.swift
//  PunchSync
//
//  Created by Subhojit Saha on 2024-12-19.
//

import SwiftUI

struct Check_in_out: View {
    
    @State private var userInput: String = ""
    
    let numberPad: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["C", "0", "⌫"]
    ]
    
    
    func handleInput(_ item: String) {
        if item == "C" {
            userInput = "" // Clear the user input
        } else if item == "⌫" {
            userInput = String(userInput.dropLast()) // Remove the last character
        } else {
            userInput += item // Add the input
        }
    }
    
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Perosnal Number")
                .font(.title)
                .padding(30)
            Text(userInput.isEmpty ? "YYMMDD-XXXX" : userInput)
                .font(.title)
                .opacity(userInput.isEmpty ? 0.3 : 1)
            Rectangle()
                .frame(width: 300, height: 1)
                .foregroundColor(.black)
                .padding(.bottom, 30)
            ForEach(numberPad, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { item in
                        Button(action: {
                            handleInput(item)
                        }) {
                            Text(item)
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(Color.gray.opacity(item.isEmpty ? 0 : 0.4))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                        .disabled(item.isEmpty) // Disable empty buttons
                    }
                }
            }
            Button(action: {
                // Your button action here
            }) {
                Text("Check In/Out")
                    .font(.title)
                    .foregroundColor(.white) // Text color
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 254/255, green: 126/255, blue: 101/255), // RGB(254, 126, 101)
                                Color(red: 229/255, green: 141/255, blue: 53/255), // RGB(229, 141, 53)
                                Color(red: 253/255, green: 151/255, blue: 9/255)   // RGB(253, 151, 9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
            .padding()
        }
        .background(Color.white)
    }

}

#Preview {
    Check_in_out()
}
