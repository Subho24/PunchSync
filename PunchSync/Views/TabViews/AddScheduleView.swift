//
//  AddScheduleView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2025-01-08.
//

import SwiftUI
import Firebase

struct AddScheduleView: View {
    @Binding var schedules: [String: [Schedule]]
    @Binding var selectedDate: Date
    @State private var selectedEmployee: String = ""
    @State private var employees: [EmployeeData] = []
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State var punchsyncfb = PunchSyncFB()

    let companyCode: String

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Employee")) {
                    Picker("Select Employee", selection: $selectedEmployee) {
                        ForEach(employees) { employee in
                            Text(employee.fullName).tag(employee.fullName)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .onChange(of: selectedEmployee) { newValue in
                        // Perform any action when employee selection changes
                    }
                }

                Section(header: Text("Shift Timing")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Schedule")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveSchedule() }.disabled(selectedEmployee.isEmpty)
            )
            .onAppear(perform: loadEmployeesData)
        }
    }

    private func loadEmployeesData() {
        punchsyncfb.loadEmployees(for: companyCode) { employees, error in
            if let error = error {
                print("Error loading employees: \(error.localizedDescription)")
            } else if let employees = employees {
                self.employees = employees

                // Cakto vlerën e parë si të përzgjedhur nëse nuk ka vlerë fillestare
                if self.selectedEmployee.isEmpty, let firstEmployee = employees.first {
                    self.selectedEmployee = firstEmployee.fullName
                }
            }
        }
    }

    private func saveSchedule() {
        // Gjej punonjësin e përzgjedhur në listën e ngarkuar të punonjësve për të marrë personalSecurityNumber
        guard let selectedEmployeeData = employees.first(where: { $0.fullName == selectedEmployee }) else {
            print("Error: Employee not found")
            return
        }

        // Referenca kryesore për të ruajtur të dhënat
        let schedulesRef = Database.database()
            .reference()
            .child("schedules")
            .child(companyCode)
            .child(formattedDate(date: selectedDate))
            .child(selectedEmployeeData.personalNumber) // Përdor personalSecurityNumber si çelës

        // Gjenero një çelës unik për regjistrimin e ri brenda personalSecurityNumber
        let newScheduleRef = schedulesRef.childByAutoId()

        let scheduleData: [String: Any] = [
            "employeeName": selectedEmployee,
            "startTime": formatTime(date: startTime),
            "endTime": formatTime(date: endTime)
        ]

        // Ruaj të dhënat në Firebase
        newScheduleRef.setValue(scheduleData) { error, _ in
            if let error = error {
                print("Error saving schedule: \(error.localizedDescription)")
            } else {
                print("Schedule saved successfully.")
                dismiss()
            }
        }
    }


    private func dismiss() {
        // Kthimi në pamjen e "ScheduleView" dhe përditësimi automatik i listës
        self.presentationMode.wrappedValue.dismiss()
    }

    private func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: date)
    }
}
