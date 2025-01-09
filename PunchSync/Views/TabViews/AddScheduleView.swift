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
    
    let companyCode: String
    let userId: String
    
    @State private var employees: [String] = [] // Lista e punonjësve që do të merret nga Firebase
    
    var body: some View {
        NavigationView {
            Form {
                // DropDown për zgjedhjen e punonjësit
                Section(header: Text("Select Employee")) {
                    Picker("Employee", selection: $selectedEmployee) {
                        ForEach(employees, id: \.self) { employee in
                            Text(employee)
                        }
                    }
                }
                
                // Zgjedhja e orarit të fillimit dhe mbarimit
                Section(header: Text("Shift Timing")) {
                    DatePicker("Start Time", selection: $shiftStartTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $shiftEndTime, displayedComponents: .hourAndMinute)
                }
                
            }
            .navigationTitle("Add Schedule")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissView()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSchedule()
                    }
                }
            }
            .onAppear {
                fetchEmployeesFromFirebase() // Thirrja për të marrë punonjësit në ngarkimin e parë të pamjes
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
    
    private func fetchEmployeesFromFirebase() {
        let databaseRef = Database.database().reference()
        let usersRef = databaseRef.child("users").child(companyCode)
        
        usersRef.observeSingleEvent(of: .value) { snapshot in
            var employeeList: [String] = []
            
            if let userData = snapshot.value as? [String: Any] {
                for (_, value) in userData {
                    if let userDict = value as? [String: Any],
                       let employeeName = userDict["name"] as? String {
                        employeeList.append(employeeName)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.employees = employeeList
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
