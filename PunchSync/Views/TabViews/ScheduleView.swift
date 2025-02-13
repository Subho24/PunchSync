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
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
    @State private var employees: [EmployeeData] = []
    @State private var showDeleteAlert: Bool = false
    @State private var scheduleToDelete: Schedule? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding(.horizontal)
                        .padding(.top)

                    Divider().padding(.horizontal)

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

                                HStack {
                     /*               // Edit button (as placeholder)
                                    Button(action: {}) {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.black)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(8)
                                    }
*/
                                    // Trash button to show the delete alert
                                    Button(action: {
                                        scheduleToDelete = schedule  // Ruajmë planifikimin që do të fshihet
                                        showDeleteAlert = true  // Aktivizojmë alert-in
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
            .onAppear(perform: {
                punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                    if success {
                        loadSchedulesAndEmployees(for: adminData.companyCode)
                    } else {
                        print("Failed to load admin data: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            })
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Confirm Deletion"),
                    message: Text("Are you sure you want to delete this schedule?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let scheduleToDelete = scheduleToDelete {
                            deleteSchedule(scheduleID: scheduleToDelete.id)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func convertStringToDate(_ timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: timeString) ?? Date()
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

    private func deleteSchedule(scheduleID: String) {
        let companyCode = adminData.companyCode
        guard !companyCode.isEmpty else { return }

        let dateKey = formattedDate(date: selectedDate)
        let ref = Database.database().reference()
            .child("schedules")
            .child(companyCode)
            .child(dateKey)

        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as? [DataSnapshot] ?? [] {
                let personalSecurityNumber = child.key
                if child.hasChild(scheduleID) {
                    ref.child(personalSecurityNumber).child(scheduleID).removeValue { error, _ in
                        if error == nil {
                            DispatchQueue.main.async {
                                self.schedules[dateKey]?.removeAll { $0.id == scheduleID }
                            }
                        }
                    }
                    return
                }
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

    func formatTime(_ timeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        return timeString
    }

    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}


struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
