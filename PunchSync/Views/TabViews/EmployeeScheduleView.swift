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
    @State private var personalSecurityNumber: String = ""  // Ky është personalSecurityNumber i përdoruesit aktual
    @State private var companyCode: String = ""  // Ky është companyCode i përdoruesit aktual

    // Funksioni për ngarkimin e orareve për përdoruesin e loguar
    private func loadSchedulesForCurrentUser() {
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
            
            // Krijo referencën për oraret duke përdorur companyCode dhe personalSecurityNumber
            let schedulesRef = Database.database().reference()
                .child("schedules")
                .child(companyCode)  // Përdor companyCode për të gjetur oraret
                .child(formattedDateString(date: selectedDate))  // Përdor datën e përzgjedhur
                .child(personalSecurityNumber)  // Përdor personalSecurityNumber për të gjetur oraret për këtë përdorues
                
            schedulesRef.observeSingleEvent(of: .value) { snapshot in
                var loadedSchedules: [EmployeeSchedule] = []

                if let scheduleInfo = snapshot.value as? [String: Any] {
                    guard let employeeName = scheduleInfo["employeeName"] as? String,
                          let startTime = scheduleInfo["startTime"] as? String,
                          let endTime = scheduleInfo["endTime"] as? String else { return }

                    // Përdor `personalSecurityNumber` si id për orarin
                    let schedule = EmployeeSchedule(
                        id: personalSecurityNumber,  // personalSecurityNumber është tani id e orarit
                        date: formattedDateString(date: selectedDate),  // Data e përzgjedhur
                        employeeName: employeeName,
                        startTime: startTime,
                        endTime: endTime
                    )
                    
                    // Shto në listën e orareve të ngarkuara
                    loadedSchedules.append(schedule)
                }

                // Pasi të mbarojë ngarkimi, përditëso të dhënat në UI
                DispatchQueue.main.async {
                    self.schedules = loadedSchedules
                }
            }
        }
    }

    // Filtron oraret për datën e përzgjedhur
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
                } else if schedules.isEmpty {
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
            .navigationTitle("Your Schedule")
            .onAppear {
                loadSchedulesForCurrentUser()
            }
        }
    }
}

#Preview {
    EmployeeScheduleView()
}
