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
                    // Calendar at the top
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                    
                    // List of schedules for the selected date
                    if let dailySchedules = schedules[formattedDate(date: selectedDate)] {
                        List {
                            ForEach(dailySchedules) { schedule in
                                HStack {
                                    Text(schedule.employee) // Employee name
                                        .font(.headline)
                                    Spacer()
                                    Text("\(formatTime(schedule.startTime)) - \(formatTime(schedule.endTime))") // Start and end times
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
            let schedulesRef = databaseRef.child("schedules").child(companyCode)
            
            schedulesRef.observeSingleEvent(of: .value) { snapshot in
                guard let scheduleData = snapshot.value as? [String: Any] else {
                    print("No schedules found.")
                    return
                }
                
                var loadedSchedules: [String: [Schedule]] = [:]
                
                for (dateKey, dailySchedule) in scheduleData {
                    guard let scheduleDicts = dailySchedule as? [String: [String: Any]] else { continue }
                    
                    let schedulesForDate = scheduleDicts.compactMap { (_, scheduleDict) -> Schedule? in
                        guard let employee = scheduleDict["employee"] as? String,
                              let startTime = scheduleDict["startTime"] as? String,
                              let endTime = scheduleDict["endTime"] as? String else { return nil }
                        
                        return Schedule(
                            id: UUID().uuidString,
                            employee: employee,
                            startTime: startTime,
                            endTime: endTime
                        )
                    }
                    loadedSchedules[dateKey] = schedulesForDate
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
        
        private func formatTime(_ dateTime: String) -> String {
            // Converts time from "yyyy-MM-dd'T'HH:mm:ssZ" to "HH:mm"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            if let date = formatter.date(from: dateTime) {
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            } else {
                return dateTime // If conversion fails, return original string
            }
        }
    }
#Preview {
    ScheduleView()
}
