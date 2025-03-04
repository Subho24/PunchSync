//
//  EmployeeScheduleView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2025-01-26.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct EmployeeSchedule: Identifiable {
    let id: String
    let date: String
    let employeeName: String
    let startTime: String
    let endTime: String
}

struct EmployeeScheduleView: View {
    @State private var schedules: [EmployeeSchedule] = []
    @State private var selectedDate: Date = Date()
    @State private var errorMessage: String?
    @State private var personalSecurityNumber: String = ""
    @State private var companyCode: String = ""

    private func loadAllSchedulesForCurrentUser() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is logged in.")
            return
        }

        let userRef = Database.database().reference().child("users").child(currentUser.uid)
        
        // Merr informacionin për përdoruesin aktual (companyCode dhe personalSecurityNumber)
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                print("Error: Could not retrieve user data.")
                return
            }
            
            guard let personalSecurityNumber = userData["personalSecurityNumber"] as? String,
                  let companyCode = userData["companyCode"] as? String else {
                print("Error: Missing personalSecurityNumber or companyCode")
                return
            }
            
            self.personalSecurityNumber = personalSecurityNumber
            self.companyCode = companyCode
            
            let schedulesRef = Database.database().reference()
                .child("schedules")
                .child(companyCode)
            
            schedulesRef.observeSingleEvent(of: .value) { snapshot in
                var loadedSchedules: [EmployeeSchedule] = []
                
             
                for child in snapshot.children {
                    guard let dateSnapshot = child as? DataSnapshot else { continue }
                    let dateKey = dateSnapshot.key
                    
                    if let employeeData = dateSnapshot.childSnapshot(forPath: personalSecurityNumber).value as? [String: Any] {
                    
                        for childSchedule in dateSnapshot.childSnapshot(forPath: personalSecurityNumber).children {
                            guard let scheduleSnapshot = childSchedule as? DataSnapshot else { continue }
                            let scheduleID = scheduleSnapshot.key
                            
                         
                            if let scheduleDetails = scheduleSnapshot.value as? [String: Any] {
                                guard let employeeName = scheduleDetails["employeeName"] as? String,
                                      let startTime = scheduleDetails["startTime"] as? String,
                                      let endTime = scheduleDetails["endTime"] as? String else {
                                    continue
                                }
                                
                           
                                let schedule = EmployeeSchedule(
                                    id: scheduleID,
                                    date: dateKey,
                                    employeeName: employeeName,
                                    startTime: startTime,
                                    endTime: endTime
                                )
                                
                                loadedSchedules.append(schedule)
                            }
                        }
                    }
                }
                
      
                DispatchQueue.main.async {
                    self.schedules = loadedSchedules
                }
            }
        }
    }

    
    private func filteredSchedules(for date: Date) -> [EmployeeSchedule] {
        let formattedDate = formattedDateString(date: date)
        return schedules.filter { $0.date == formattedDate }
    }

   
    private func formattedDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    
    private func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        return timeString
    }

    var body: some View {
        NavigationView {
            VStack {
               
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()

                Divider().padding(.horizontal)

                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if filteredSchedules(for: selectedDate).isEmpty {
                    Text("No schedules available for this date.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredSchedules(for: selectedDate)) { schedule in
                        VStack(alignment: .leading) {
                            Text(schedule.employeeName)
                                .font(.headline)
                            Text("Shift: \(formatTime(schedule.startTime)) - \(formatTime(schedule.endTime))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("My Schedule")
            .onAppear {
                loadAllSchedulesForCurrentUser()
            }
        }
    }
}

#Preview {
    EmployeeScheduleView()
}
