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
    @State private var schedules: [EmployeeSchedule] = [] // Lista e plotë e orareve
    @State private var selectedDate: Date = Date() // Data e përzgjedhur nga përdoruesi
    @State private var errorMessage: String? // Për të ruajtur gabimet
    @State private var personalSecurityNumber: String = "" // personalSecurityNumber i përdoruesit aktual
    @State private var companyCode: String = "" // companyCode i përdoruesit aktual

    // Funksioni për ngarkimin e të gjitha orareve për përdoruesin aktual
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
            
            // Krijo referencën për të gjitha datat në `schedules` për këtë përdorues
            let schedulesRef = Database.database().reference()
                .child("schedules")
                .child(companyCode)
            
            schedulesRef.observeSingleEvent(of: .value) { snapshot in
                var loadedSchedules: [EmployeeSchedule] = []
                
                // Kalon nëpër të gjitha datat
                for child in snapshot.children {
                    guard let dateSnapshot = child as? DataSnapshot else { continue }
                    let dateKey = dateSnapshot.key // Data në formatin e ruajtur në Firebase
                    
                    // Kontrollon nëse ka të dhëna për këtë personalSecurityNumber
                    if let employeeData = dateSnapshot.childSnapshot(forPath: personalSecurityNumber).value as? [String: Any] {
                        // Kalon për secilin scheduleID në këtë datë
                        for childSchedule in dateSnapshot.childSnapshot(forPath: personalSecurityNumber).children {
                            guard let scheduleSnapshot = childSchedule as? DataSnapshot else { continue }
                            let scheduleID = scheduleSnapshot.key  // scheduleID si çelës i orarit
                            
                            // Merr informacionet për orarin
                            if let scheduleDetails = scheduleSnapshot.value as? [String: Any] {
                                guard let employeeName = scheduleDetails["employeeName"] as? String,
                                      let startTime = scheduleDetails["startTime"] as? String,
                                      let endTime = scheduleDetails["endTime"] as? String else {
                                    continue
                                }
                                
                                // Krijon një objekt të `EmployeeSchedule`
                                let schedule = EmployeeSchedule(
                                    id: scheduleID, // scheduleID është tani id unike për këtë orar
                                    date: dateKey,   // Data e ruajtur në Firebase
                                    employeeName: employeeName,
                                    startTime: startTime,
                                    endTime: endTime
                                )
                                
                                loadedSchedules.append(schedule)
                            }
                        }
                    }
                }
                
                // Pasi të ngarkohen të gjitha oraret, përditëson listën
                DispatchQueue.main.async {
                    self.schedules = loadedSchedules
                }
            }
        }
    }

    // Filtron oraret sipas datës së përzgjedhur nga përdoruesi
    private func filteredSchedules(for date: Date) -> [EmployeeSchedule] {
        let formattedDate = formattedDateString(date: date)
        return schedules.filter { $0.date == formattedDate }
    }

    // Formatimi i datës për nevojat e Firebase (p.sh. "yyyy-MM-dd")
    private func formattedDateString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // Formatimi i orarit për ta shfaqur në mënyrë miqësore (p.sh. "h:mm a")
    private func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: timeString) else { return timeString }

        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationView {
            VStack {
                // Data Picker për të përzgjedhur një datë
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()

                Divider().padding(.horizontal)

                // Shfaqja e mesazheve të gabimeve ose orareve
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
