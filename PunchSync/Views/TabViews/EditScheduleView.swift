//
//  EditScheduleView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2025-02-18.
//

import SwiftUI
import Firebase

struct EditScheduleView: View {
    @Binding var schedule: Schedule 
    @Binding var schedules: [String: [Schedule]]
    @Binding var selectedDate: Date
    @State private var selectedEmployee: String
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var employees: [EmployeeData] = []
    @State var punchsyncfb = PunchSyncFB()
    
    let companyCode: String

    @Environment(\.presentationMode) var presentationMode

    init(schedule: Binding<Schedule>, schedules: Binding<[String: [Schedule]]>, selectedDate: Binding<Date>, companyCode: String) {
        _schedule = schedule
        _schedules = schedules
        _selectedDate = selectedDate
        self.companyCode = companyCode
        
        _selectedEmployee = State(initialValue: schedule.wrappedValue.employeeName)
        
        _startTime = State(initialValue: Date())
        _endTime = State(initialValue: Date())
    }

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
                    .onChange(of: selectedDate) { oldValue, newValue in
                        print("Date changed from \(oldValue) to \(newValue)")
                        // Shto logjikën tënde këtu
                    }

                }

                Section(header: Text("Shift Timing")) {
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Edit Schedule")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save Changes") { saveSchedule() }
                    .disabled(selectedEmployee.isEmpty)
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

           
                if employees.first(where: { $0.fullName == selectedEmployee }) != nil {
      
                    self.startTime = convertStringToDate(schedule.startTime)
                    self.endTime = convertStringToDate(schedule.endTime)
                }
            }
        }
    }

    private func saveSchedule() {
        guard let selectedEmployeeData = employees.first(where: { $0.fullName == selectedEmployee }) else {
            print("Error: Employee not found")
            return
        }

       
        let schedulesRef = Database.database()
            .reference()
            .child("schedules")
            .child(companyCode)
            .child(formattedDate(date: selectedDate))
            .child(selectedEmployeeData.personalNumber)

      
        let scheduleRef = schedulesRef.child(schedule.id)

      
        let scheduleData: [String: Any] = [
            "employeeName": selectedEmployee,
            "startTime": formatTime(date: startTime),
            "endTime": formatTime(date: endTime)
        ]

        
        scheduleRef.updateChildValues(scheduleData) { error, _ in
            if let error = error {
                print("Error updating schedule: \(error.localizedDescription)")
            } else {
                print("Schedule updated successfully.")
                dismiss()
            }
        }
    }

    private func dismiss() {
        
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

    private func convertStringToDate(_ timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: timeString) ?? Date()
    }
}
