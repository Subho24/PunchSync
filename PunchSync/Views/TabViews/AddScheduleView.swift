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
                // DropDown për zgjedhjen e punonjësit
                Section(header: Text("Select Employee")) {
                    Picker("Employee", selection: $selectedEmployee) {
                        ForEach(employees) { employee in
                            Text(employee.fullName)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                // Zgjedhja e orarit të fillimit dhe përfundimit
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
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let formattedStartTime = formatter.string(from: shiftStartTime)
        let formattedEndTime = formatter.string(from: shiftEndTime)
        
        let newSchedule = Schedule(
            id: UUID().uuidString,
            employee: selectedEmployee,
            startTime: formattedStartTime,
            endTime: formattedEndTime
        )
        
        // Ruajmë në Firebase
        let databaseRef = Database.database().reference()
        let scheduleRef = databaseRef.child("schedules").child(companyCode).child(userId).childByAutoId()
        scheduleRef.setValue([
            "employee": newSchedule.employee,
            "startTime": newSchedule.startTime,
            "endTime": newSchedule.endTime
        ]) { error, _ in
            if let error = error {
                print("Error saving schedule: \(error.localizedDescription)")
            } else {
                print("Schedule saved successfully")
                DispatchQueue.main.async {
                    let dateKey = String(newSchedule.startTime.prefix(10)) // YYYY-MM-DD
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
    
    private func dismissView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.rootViewController?.dismiss(animated: true)
            }
        }
    }
}
