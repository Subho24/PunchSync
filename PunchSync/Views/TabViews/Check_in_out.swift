import SwiftUI
import Firebase

struct Check_in_out: View {
    
    @State private var userInput: String = ""
    @State private var showButtons = false
    
    
    var punchRecords: [String: Any] = [:]
    
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
    
    func checkInUser(_ personalNummer: String) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let currentDateTimeString = dateFormatter.string(from: Date())
        
        print("\(userInput) \(currentDateTimeString)")
        
        let punchData: [String: String] = [
            "checkInTime": currentDateTimeString,
            "checkOutTime": "",
            "breakStartTime":  "",
            "breakEndTime": ""
        ]
        
        ref.child("punch_records").child(personalNummer).setValue(punchData)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Text("Personal Number")
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
                    if !userInput.isEmpty && ValidationUtils.isValidPersonalNumber(userInput) {
                        showButtons = true
                        checkInUser(userInput)
                    }
                    
                }) {
                    ButtonView(buttontext: "Next")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                
                if showButtons{
                    Button(action: {
                        // checkin / out employee
                    }) {
                        ButtonView(buttontext: "check-In")
                    }
                }
            }
        }
    }
}

struct Check_in_out_Previews: PreviewProvider {
    static var previews: some View {
        Check_in_out()
    }
}
