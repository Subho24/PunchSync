//
//  AddScheduleView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2025-01-08.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct AddScheduleView: View {
    @Binding var schedules: [String: [Schedule]]
    @Binding var selectedDate: Date
    @State private var selectedEmployee: String = ""
    @State private var shiftStartTime: Date = Date()
    @State private var shiftEndTime: Date = Date()
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
    @State private var employees: [EmployeeData] = []
    @State private var isLoading = true

    let companyCode: String
    let userId: String

    var body: some View {
        NavigationView {
            Form {
                // Dropdown for selecting the employee
                Section(header: Text("Select Employee")) {
                    Picker("Employee", selection: $selectedEmployee) {
                        ForEach(employees) { employee in
                            Text(employee.fullName)
                                .tag(employee.personalNumber)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }

                // Select shift start and end times
                Section(header: Text("Select Shift Times")) {
                    DatePicker("Start Time", selection: $shiftStartTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(CompactDatePickerStyle())

                    DatePicker("End Time", selection: $shiftEndTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(CompactDatePickerStyle())
                }
            }
            .navigationTitle("Add Schedule")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismissView()
                },
                trailing: Button("Save") {
                    saveSchedule()
                }
            )
            .task {
                punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                    if success {
                        print("Admin data loaded successfully")
                        
                        punchsyncfb.loadEmployees(for: adminData.companyCode) { loadedEmployees, error in
                            if let loadedEmployees = loadedEmployees {
                                DispatchQueue.main.async {
                                    self.employees = loadedEmployees
                                    self.isLoading = false
                                }
                                print("Employees loaded: \(loadedEmployees)")
                            } else if let error = error {
                                print("Error loading employees: \(error.localizedDescription)")
                            }
                        }
                    } else if let error = error {
                        print("Error loading admin data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    private func saveSchedule() {
        // Ensure a valid employee is selected
        guard let selectedEmployeeData = employees.first(where: { $0.personalNumber == selectedEmployee }) else {
            print("Employee not found")
            return
        }
        
        // Format the time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let formattedStartTime = formatter.string(from: shiftStartTime)
        let formattedEndTime = formatter.string(from: shiftEndTime)
        let dateKey = formattedDate(selectedDate) // Use selected date as key
        
        // Create a new schedule
        let newSchedule = Schedule(
            id: UUID().uuidString,
            employee: selectedEmployeeData.fullName,
            startTime: formattedStartTime,
            endTime: formattedEndTime
        )
        
        // Save to Firebase
        let databaseRef = Database.database().reference()
        let scheduleRef = databaseRef
            .child("schedules")
            .child(companyCode)
            .child(dateKey)
            .child(selectedEmployeeData.personalNumber)
        
        scheduleRef.setValue([
            "employee": selectedEmployeeData.fullName,
            "startTime": formattedStartTime,
            "endTime": formattedEndTime
        ]) { error, _ in
            if let error = error {
                print("Error saving schedule: \(error.localizedDescription)")
            } else {
                print("Schedule saved successfully")
                DispatchQueue.main.async {
                    // Update UI with new data
                    if schedules[dateKey] != nil {
                        schedules[dateKey]?.append(newSchedule)
                    } else {
                        schedules[dateKey] = [newSchedule]
                    }
                    dismissView()
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func dismissView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController?.dismiss(animated: true)
            }
        }
    }
}
