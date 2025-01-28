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
            ScrollView {
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
                                        scheduleToEdit = schedule
                                        newEmployeeName = schedule.employeeName
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
                .padding(.bottom)
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
                        Button("Cancel") {
                            showEditScheduleView = false
                        }
                        .padding()
                        .foregroundColor(.red)

                        Spacer()

                        Button("Save Changes") {
                            // Check that we have valid data and proceed with async update
                            guard let scheduleToEdit = scheduleToEdit else {
                                print("Schedule to edit not found.")
                                return
                            }
                            
                            let startTimeString = convertDateToString(newStartTime)
                            let endTimeString = convertDateToString(newEndTime)

                            if newEmployeeName.isEmpty || startTimeString.isEmpty || endTimeString.isEmpty {
                                print("Invalid data provided")
                                return
                            }

                            Task {
                                let result = await editSchedule(
                                    scheduleID: scheduleToEdit.id,
                                    dateKey: formattedDate(date: selectedDate),
                                    newEmployeeName: newEmployeeName,
                                    newStartTime: startTimeString,
                                    newEndTime: endTimeString,
                                    companyCode: adminData.companyCode
                                )

                                if result {
                                    loadSchedulesAndEmployees(for: adminData.companyCode)
                                    showEditScheduleView = false
                                } else {
                                    print("Failed to update schedule")
                                }
                            }
                        }
                        .disabled(newEmployeeName.isEmpty || newStartTime == Date() || newEndTime == Date())
                        .padding()
                        .foregroundColor(.blue)
                    }

                    Text("Edit schedule for \(scheduleToEdit?.employeeName ?? "")")
                        .font(.headline)
                        .padding()

                    Form {
                        Text(scheduleToEdit?.employeeName ?? "")
                            .font(.body)
                            .foregroundColor(.gray)

                        DatePicker("Start Time", selection: $newStartTime, displayedComponents: .hourAndMinute)
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
                            deleteSchedule(dateKey: scheduleToDelete.dateKey,
                                            personalSecurityNumber: scheduleToDelete.scheduleID,
                                            scheduleID: scheduleToDelete.scheduleID)
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
                "startTime": newStartTime,
                "endTime": newEndTime
            ]

            ref.updateChildValues(updatedData) { error, _ in
                continuation.resume(returning: error == nil)
            }
        }
    }

    private func fetchSchedules(for companyCode: String) {
        guard !companyCode.isEmpty else {
            print("Company code is empty!")
            return
        }

        let schedulesRef = Database.database().reference().child("schedules").child(companyCode)

        schedulesRef.observe(.value) { snapshot in
            var loadedSchedules: [String: [Schedule]] = [:]

            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let dateKey = child.key // Data, p.sh., "2025-01-26"
                print("Date Key: \(dateKey)")

                if let personalSecurityNumbers = child.value as? [String: Any] {
                    for (personalSecurityNumber, scheduleData) in personalSecurityNumbers {
                        print("Personal Security Number: \(personalSecurityNumber)")

                        if let scheduleEntries = scheduleData as? [String: Any] {
                            for (scheduleID, scheduleInfo) in scheduleEntries {
                                if let scheduleDetails = scheduleInfo as? [String: Any] {
                                    let employeeName = scheduleDetails["employeeName"] as? String ?? "Unknown"
                                    let startTime = scheduleDetails["startTime"] as? String ?? ""
                                    let endTime = scheduleDetails["endTime"] as? String ?? ""

                                    let schedule = Schedule(id: scheduleID, employeeName: employeeName, startTime: startTime, endTime: endTime)

                                    if loadedSchedules[dateKey] == nil {
                                        loadedSchedules[dateKey] = []
                                    }

                                    loadedSchedules[dateKey]?.append(schedule)
                                }
                            }
                        }
                    }
                }
            }

            self.schedules = loadedSchedules
        }
    }

    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func formatTime(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = formatter.date(from: time) else { return "" }

        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func deleteSchedule(dateKey: String, personalSecurityNumber: String, scheduleID: String) {
        let ref = Database.database().reference()
            .child("schedules")
            .child(adminData.companyCode)
            .child(dateKey)
            .child(personalSecurityNumber)
            .child(scheduleID)

        ref.removeValue { error, _ in
            if let error = error {
                print("Error deleting schedule: \(error.localizedDescription)")
            } else {
                print("Schedule deleted successfully.")
                // Rifreskoni oraret pas fshirjes
                loadSchedulesAndEmployees(for: adminData.companyCode)
            }
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
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "HH:mm"  // Formati i dëshiruar për shfaqje
            return formatter.string(from: date)
        }
        return timeString  // Kthehet string origjinal nëse nuk mund të formohet
    }

#Preview {
    ScheduleView()
}
