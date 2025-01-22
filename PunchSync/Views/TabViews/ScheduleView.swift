//  ScheduleView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

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
    let employeeName: String
    let startTime: String
    let endTime: String
}

struct ScheduleView: View {
    @State private var schedules: [String: [Schedule]] = [:]
    @State private var selectedDate: Date = Date()
    @State private var showAddScheduleView: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var scheduleToDelete: (dateKey: String, scheduleID: String)? = nil
    @State private var showEditScheduleView: Bool = false
    @State private var scheduleToEdit: Schedule? = nil
    @State private var newEmployeeName: String = ""
    @State private var newStartTime: Date = Date()
    @State private var newEndTime: Date = Date()
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
    @State private var employees: [EmployeeData] = []

    var body: some View {
        NavigationView {
            ScrollView {  // Add ScrollView to make the whole view scrollable
                VStack {
                    // Date Picker
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding(.horizontal)
                        .padding(.top)

                    Divider().padding(.horizontal)

                    // Display schedules for selected date
                                       if let dailySchedules = schedules[formattedDate(date: selectedDate)] {
                                           ForEach(dailySchedules.sorted(by: {
                                               convertStringToDate($0.startTime) < convertStringToDate($1.startTime)
                                           })) { schedule in
                                               HStack {
                                                   VStack(alignment: .leading) {
                                                       Text(schedule.employeeName)
                                                           .font(.headline)
                                                           .foregroundColor(.black)
                                                       Text("\(formatTime(schedule.startTime)) - \(formatTime(schedule.endTime))")
                                                           .font(.subheadline)
                                                           .foregroundColor(.gray)
                                                   }

                                Spacer()

                                // Buttons for edit and delete
                                HStack {
                                    Button(action: {
                                        // Show the edit screen with the selected schedule
                                        scheduleToEdit = schedule
                                        newEmployeeName = schedule.employeeName
                                        // Convert stored time to Date
                                        newStartTime = convertStringToDate(schedule.startTime)
                                        newEndTime = convertStringToDate(schedule.endTime)
                                        showEditScheduleView.toggle()
                                    }) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.black)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(8)
                                    }

                                    Button(action: {
                                        // Show delete confirmation
                                        scheduleToDelete = (dateKey: formattedDate(date: selectedDate), scheduleID: schedule.id)
                                        showDeleteConfirmation = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .padding(8)
                                            .background(Color.red.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.leading, 10)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                        }
                    } else {
                        Text("No schedules available for this date.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding(.bottom)  // Add some padding at the bottom for better scrolling
            }
            .navigationTitle("Schedules")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddScheduleView.toggle() }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddScheduleView) {
                AddScheduleView(
                    schedules: $schedules,
                    selectedDate: $selectedDate,
                    companyCode: adminData.companyCode
                )
            }
            .sheet(isPresented: $showEditScheduleView) {
                VStack {
                    HStack {
                        // Cancel Button
                        Button("Cancel") {
                            // Mbyll ekranin pa ruajtur ndryshimet
                            showEditScheduleView = false
                        }
                        .padding()
                        .foregroundColor(.red)

                        Spacer()

                        // Save Changes Button
                        Button("Save Changes") {
                            Task {
                                let result = await editSchedule(
                                    scheduleID: scheduleToEdit?.id ?? "",
                                    dateKey: formattedDate(date: selectedDate),
                                    newEmployeeName: newEmployeeName,
                                    newStartTime: convertDateToString(newStartTime),
                                    newEndTime: convertDateToString(newEndTime),
                                    companyCode: adminData.companyCode
                                )
                                if result {
                                    // Refresh the schedule list after editing
                                    loadSchedulesAndEmployees(for: adminData.companyCode)
                                    showEditScheduleView = false
                                }
                            }
                        }
                        .disabled(newEmployeeName.isEmpty || newStartTime == Date() || newEndTime == Date())
                        .padding()
                        .foregroundColor(.blue)
                    }

                    // Edit Form
                    Text("Edit schedule for \(scheduleToEdit?.employeeName ?? "")")
                        .font(.headline)
                        .padding()

                    Form {
                        // Display employee name (non-editable)
                        Text(scheduleToEdit?.employeeName ?? "")
                            .font(.body)
                            .foregroundColor(.gray)

                        // Start Time DatePicker
                        DatePicker("Start Time", selection: $newStartTime, displayedComponents: .hourAndMinute)

                        // End Time DatePicker
                        DatePicker("End Time", selection: $newEndTime, displayedComponents: .hourAndMinute)
                    }
                }
                .padding()
            }

            // Delete Schedule Alert
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Schedule"),
                    message: Text("Are you sure you want to delete this schedule?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let scheduleToDelete = scheduleToDelete {
                            deleteSchedule(dateKey: scheduleToDelete.dateKey, scheduleID: scheduleToDelete.scheduleID)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear(perform: {
                punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                    if success {
                        loadSchedulesAndEmployees(for: adminData.companyCode)
                    } else {
                        print("Failed to load admin data: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            })
        }
    }

    private func convertStringToDate(_ timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: timeString) ?? Date()
    }

    private func convertDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: date)
    }

    private func loadSchedulesAndEmployees(for companyCode: String) {
        punchsyncfb.loadEmployees(for: companyCode) { employees, error in
            if let error = error {
                print("Error loading employees: \(error.localizedDescription)")
                return
            }

            if let employees = employees {
                self.employees = employees
            }

            fetchSchedules(for: companyCode)
        }
    }

    func editSchedule(
        scheduleID: String,
        dateKey: String,
        newEmployeeName: String,
        newStartTime: String,
        newEndTime: String,
        companyCode: String
    ) async -> Bool {
        guard !companyCode.isEmpty else { return false }

        return await withCheckedContinuation { continuation in
            let ref = Database.database().reference()
                .child("schedules")
                .child(companyCode)
                .child(dateKey)
                .child(scheduleID)

            let updatedData: [String: Any] = [
                "employeeName": newEmployeeName,
                "startTime": newStartTime,
                "endTime": newEndTime
            ]

            ref.updateChildValues(updatedData) { error, _ in
                continuation.resume(returning: error == nil)
            }
        }
    }

    private func fetchSchedules(for companyCode: String) {
        guard !companyCode.isEmpty else { return }
        let schedulesRef = Database.database().reference().child("schedules").child(companyCode)

        schedulesRef.observe(.value) { snapshot in
            var loadedSchedules: [String: [Schedule]] = [:]
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let dateKey = child.key
                if let dailySchedules = child.value as? [String: [String: Any]] {
                    loadedSchedules[dateKey] = dailySchedules.compactMap { (id, scheduleData) in
                        guard let employeeName = scheduleData["employeeName"] as? String,
                              let startTime = scheduleData["startTime"] as? String,
                              let endTime = scheduleData["endTime"] as? String else { return nil }

                        return Schedule(
                            id: id,
                            employeeName: employeeName,
                            startTime: startTime,
                            endTime: endTime
                        )
                    }
                }
            }

            DispatchQueue.main.async {
                self.schedules = loadedSchedules
            }
        }
    }

    private func deleteSchedule(dateKey: String, scheduleID: String) {
        let schedulesRef = Database.database().reference().child("schedules").child(adminData.companyCode).child(dateKey).child(scheduleID)

        schedulesRef.removeValue { error, _ in
            if error != nil {
                print("Error deleting schedule.")
            } else {
                loadSchedulesAndEmployees(for: adminData.companyCode)
            }
        }
    }

    private func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: timeString) else { return timeString }

        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    ScheduleView()
}
