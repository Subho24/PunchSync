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
    @State private var showDeleteConfirmation: Bool = false
    @State private var scheduleToDelete: Schedule? = nil
    
    let companyCode = "companyCode1"
    let userId = "userId1"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Calendar at the top
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGroupedBackground)))
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // List of schedules for the selected date
                    if let dailySchedules = schedules[formattedDate(date: selectedDate)] {
                        VStack(spacing: 10) {
                            ForEach(dailySchedules) { schedule in
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(schedule.employee) // Employee name
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("\(formatTime(schedule.startTime)) - \(formatTime(schedule.endTime))") // Start and end times
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    HStack(spacing: 20) {
                                        // Edit icon
                                        Image(systemName: "square.and.pencil")
                                            .font(.title2)
                                            .foregroundColor(.black)
                                            .onTapGesture {
                                                print("Edit tapped for \(schedule.employee)")
                                            }
                                        
                                        // Delete icon
                                        Image(systemName: "trash")
                                            .font(.title2)
                                            .foregroundColor(.red)
                                            .onTapGesture {
                                                scheduleToDelete = schedule
                                                showDeleteConfirmation = true
                                            }
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    } else {
                        Text("No schedules for this day")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .navigationTitle("Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddScheduleView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
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
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Confirm Delete"),
                    message: Text("Are you sure you want to delete this schedule?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let schedule = scheduleToDelete {
                            deleteSchedule(schedule)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                fetchSchedulesFromFirebase()
            }
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
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
                
                let schedulesForDate = scheduleDicts.compactMap { (id, scheduleDict) -> Schedule? in
                    guard let employee = scheduleDict["employee"] as? String,
                          let startTime = scheduleDict["startTime"] as? String,
                          let endTime = scheduleDict["endTime"] as? String else { return nil }
                    
                    return Schedule(
                        id: id,
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
    
    private func deleteSchedule(_ schedule: Schedule) {
        let databaseRef = Database.database().reference()
        let dateKey = formattedDate(date: selectedDate)
        let scheduleRef = databaseRef
            .child("schedules")
            .child(companyCode)
            .child(dateKey)
            .child(schedule.id)
        
        scheduleRef.removeValue { error, _ in
            if let error = error {
                print("Error deleting schedule: \(error.localizedDescription)")
            } else {
                print("Schedule deleted successfully")
                DispatchQueue.main.async {
                    if let index = schedules[dateKey]?.firstIndex(where: { $0.id == schedule.id }) {
                        schedules[dateKey]?.remove(at: index)
                    }
                }
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
