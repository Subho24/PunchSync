//
//  ScheduleView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

import SwiftUI
import Firebase

struct Schedule: Identifiable {
    let id: String
    let employee: String
    let startTime: String
    let endTime: String
}

struct ScheduleView: View {
    @State private var schedules: [String: [Schedule]] = [:]
    @State private var selectedDate: Date = Date()
    @State private var showAddScheduleView: Bool = false

    
    let companyCode = "companyCode1"
    let userId = "userId1"
    
    var body: some View {
        NavigationView {
            VStack {
                // Kalendari në krye
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                // Lista e orareve për datën e zgjedhur
                if let dailySchedules = schedules[formattedDate(date: selectedDate)] {
                    List {
                        ForEach(dailySchedules) { schedule in
                            VStack(alignment: .leading) {
                                Text("\(schedule.startTime) - \(schedule.endTime)")
                                    .font(.headline)
                                Text(schedule.employee)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } else {
                    Text("No schedules for this day")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddScheduleView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddScheduleView) {
                AddScheduleView(
                    schedules: $schedules,
                    selectedDate: $selectedDate,
                    companyCode: companyCode,
                    userId: userId
                )
            }
            .onAppear {
                fetchSchedulesFromFirebase()
            }
        }
    }
    
    private func fetchSchedulesFromFirebase() {
        let databaseRef = Database.database().reference()
        let schedulesRef = databaseRef.child("schedules").child(companyCode).child(userId)
        
        schedulesRef.observeSingleEvent(of: .value) { snapshot in
            guard let scheduleData = snapshot.value as? [String: Any] else {
                print("No schedules found.")
                return
            }
            
            var loadedSchedules: [String: [Schedule]] = [:]
            
            for (_, value) in scheduleData {
                guard let scheduleDict = value as? [String: Any],
                      let employee = scheduleDict["employee"] as? String,
                      let startTime = scheduleDict["startTime"] as? String,
                      let endTime = scheduleDict["endTime"] as? String else { continue }
                
                let schedule = Schedule(
                    id: UUID().uuidString,
                    employee: employee,
                    startTime: startTime,
                    endTime: endTime
                )
                
                let dateKey = startTime.split(separator: "T").first.map(String.init) ?? ""
                if loadedSchedules[dateKey] != nil {
                    loadedSchedules[dateKey]?.append(schedule)
                } else {
                    loadedSchedules[dateKey] = [schedule]
                }
            }
            
            DispatchQueue.main.async {
                self.schedules = loadedSchedules
            }
        }
    }
    
    private func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    ScheduleView()
}
