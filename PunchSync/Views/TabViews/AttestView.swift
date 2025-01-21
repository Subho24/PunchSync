//
//  AttestView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct AttestView: View { // Make the data display properly. Create a function to get user name using the personnummer. Create a loop if a same user has multiple attests on the same day
    
    @State private var isChecked: Bool = false
    @State private var earliestPunchDate: String = ""
    @State private var allDatesArray: [Date] = []
    @State private var allAttestData: [String: [String: [String: String]]] = [:]
    @State private var punchRecords: [String: Any] = [:]

    
    func generateDateArray(from startDateString: String, punchRecords: [String: Any]) {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyy-MM-dd"
           
           // Convert input string to Date
           guard let startDate = dateFormatter.date(from: startDateString) else {
               return
           }
           
           let calendar = Calendar.current
           var dates: [Date] = []
           var current = startDate
           let currentDate = Date()
           
           // Generate the array of dates
           while current <= currentDate {
               dates.append(current)
               if let nextDay = calendar.date(byAdding: .day, value: 1, to: current) {
                   current = nextDay
               } else {
                   break
               }
           }
           
           // Transform punchRecords into required format
           var attestData: [String: [String: [String: String]]] = [:]
           
           for (userId, records) in punchRecords {
               if let userRecords = records as? [String: Any] {
                   for (date, punches) in userRecords {
                       if let punchDetails = punches as? [String: String] {
                           if attestData[date] == nil {
                               attestData[date] = [:]
                           }
                           attestData[date]?[userId] = punchDetails
                       } else if let punchList = punches as? [[String: String]] {
                           // If multiple punches exist for the same date, merge them
                           for punch in punchList {
                               if attestData[date] == nil {
                                   attestData[date] = [:]
                               }
                               attestData[date]?[userId] = punch
                           }
                       }
                   }
               }
           }
           
           // Update state variables on the main thread
           DispatchQueue.main.async {
               allDatesArray = dates
               allAttestData = attestData
           }
       }
    
    func getEarliestPunchDate(completion: @escaping (String?) -> Void) {
        let ref = Database.database().reference().child("punch_records")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            
            // Extract the data from the snapshot and store it in punchRecords
            if let value = snapshot.value as? [String: Any] {
                self.punchRecords = value
            }
            
            var dates: [String] = []
            
            // Iterate through each user (like "199103151180")
            for (userId, userData) in punchRecords {
                if let userPunchData = userData as? [String: Any] {
                    // Iterate through the dates for each user
                    for (date, _) in userPunchData {
                        dates.append(date)
                    }
                }
            }
            
            // Find the earliest date
            let earliestDate = dates.sorted().first
            completion(earliestDate)
        }
    }
    
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"  // Use the format that matches your data
        return dateFormatter.string(from: date)
    }
    
    func getUserInfo(_ personnummer: String) -> String {
        print(Auth.auth().currentUser)
        var ref = Database.database().reference()
        
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                for (user, userData) in value {
                    print(user, "user")
                    print(userData, "data")
                }
            }
        }
        return ""
    }






    
    var body: some View {
        VStack {
            VStack {
                Text("Attests")
            }
            .padding(.top, 50)
            .padding(.leading, 30)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(Color(hex: "ECE9D4"))
            
            ScrollView {
                ForEach(allDatesArray, id: \.self) { date in
                    VStack {
                        VStack {
                            HStack {
                                // Ensure the date is a String or Date, then format it as needed
                                if let dateObject = date as? Date {
                                    let formattedDate = convertDateToString(date: dateObject)
                                    Text(formattedDate)
                                } else if let stringDate = date as? String {
                                    Text(stringDate)
                                } else {
                                    Text("Invalid date")
                                }
                                Spacer()
                            }
                            .padding()
                            Rectangle()
                                .frame(width: .infinity, height: 1)
                                .foregroundColor(.black)
                            
                            // Convert date to string for accessing allAttestData
                            let dateString = convertDateToString(date: date as? Date ?? Date())
                            
                            // Check if data exists for the current date (converted to string)
                            if let attestDataForDate = allAttestData[dateString] {
                                // Data exists for this date, display it
                                ForEach(attestDataForDate.keys.sorted(), id: \.self) { userId in
                                    if let userAttestData = attestDataForDate[userId] {
                                        VStack {
                                            
                                            VStack {
                                                Rectangle()
                                                    .fill(Color(hex: "8BC5A3")) // Background color
                                                    .frame(height: 80) // Set fixed height for each attest entry
                                                    .cornerRadius(20)
                                                    .overlay(
                                                        HStack {
                                                            Spacer()
                                                            VStack {
                                                                Text("User ID: \(userId)")
                                                                    .foregroundColor(.white)
                                                                Text("Check-In: \(userAttestData["checkInTime"] ?? "N/A")")
                                                                    .foregroundColor(.white)
                                                                Text("Check-Out: \(userAttestData["checkOutTime"] ?? "N/A")")
                                                                    .foregroundColor(.white)
                                                            }
                                                            Spacer()
                                                            Button(action: {
                                                                isChecked.toggle()
                                                            }) {
                                                                Image(systemName: isChecked ? "checkmark.square.fill" : "circle")
                                                                    .resizable()
                                                                    .frame(width: 30, height: 30)
                                                                    .foregroundColor(isChecked ? Color(hex: "36906B") : Color.black)
                                                                    .background(Color.white)
                                                                    .clipShape(Circle())
                                                            }
                                                            .padding(20)
                                                        }
                                                    )
                                            }
                                        }
                                        .padding([.leading, .trailing], 10)
                                    }
                                }
                            } else {
                                // No data for this date, display a placeholder
                                Text("No records for this date")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity) // Allow it to stretch horizontally
                    }
                    .padding(.vertical) // Add vertical padding between each date's VStack to prevent overlap
                }

                


            }
            
        }
        .onAppear{
            getEarliestPunchDate { earliestDate in
                if let date = earliestDate {
                    earliestPunchDate = date
                    print("Earliest Punch Record Date: \(date)")
                    generateDateArray(from: date, punchRecords: punchRecords) // Now we call generateDateArray AFTER setting earliestPunchDate
                } else {
                    print("No date")
                }
            }
            getUserInfo("20020246656")
        }
        .ignoresSafeArea()
        }

    
    }


#Preview {
    AttestView()
}
