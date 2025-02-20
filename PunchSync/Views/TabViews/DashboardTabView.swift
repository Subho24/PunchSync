import SwiftUI
import Firebase
import FirebaseAuth

struct DashboardTabView: View {
    @StateObject private var adminData = AdminData()
    @State var punchsyncfb = PunchSyncFB()
    @Binding var isLocked: Bool
    @State var showAdminForm: Bool = false
    @State private var unusedPassword: String = ""

    @State private var checkedInUsers: [CheckedInUser] = []

    struct CheckedInUser: Identifiable {
        let id = UUID() // Needed for List
        let fullName: String
        let personalSecurityNumber: String
    }

    func fetchCheckedInUsers(for companyCode: String) {
        let databaseRef = Database.database().reference()
        let currentDateString = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let today = currentDateString.replacingOccurrences(of: "/", with: "-")

        databaseRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let punchRecords = value["punch_records"] as? [String: Any],
                  let users = value["users"] as? [String: Any] else {
                checkedInUsers = []
                return
            }

            var newCheckedInUsers: [CheckedInUser] = []

            for (personalSecurityNumber, records) in punchRecords {
                guard let dailyRecords = records as? [String: Any] else { continue }

                let matchedUsers = users.values.compactMap { $0 as? [String: Any] }.filter {
                    $0["personalSecurityNumber"] as? String == ValidationUtils.formatPersonalNumber(personalSecurityNumber)
                }

                guard let user = matchedUsers.first(where: { $0["companyCode"] as? String == companyCode }) else { continue }

                if let todayRecords = dailyRecords[today] {
                    let recordsArray: [[String: Any]]

                    if let singleRecord = todayRecords as? [String: Any] {
                        recordsArray = [singleRecord]
                    } else if let multipleRecords = todayRecords as? [[String: Any]] {
                        recordsArray = multipleRecords
                    } else {
                        continue
                    }

                    for record in recordsArray {
                        let checkInTime = record["checkInTime"] as? String
                        let checkOutTime = record["checkOutTime"] as? String

                        if checkInTime != nil && (checkOutTime == nil || checkOutTime!.isEmpty || isTimeLaterThanNow(checkOutTime!)) {
                            let fullName = user["fullName"] as? String ?? "Unknown"
                            newCheckedInUsers.append(CheckedInUser(fullName: fullName, personalSecurityNumber: personalSecurityNumber))
                            break
                        }
                    }
                }
            }

            checkedInUsers = newCheckedInUsers // Update the state
        }
    }

    func isTimeLaterThanNow(_ timeString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let timeDate = dateFormatter.date(from: timeString) else { return false }
        return timeDate > Date()
    }

    var body: some View {
        VStack(spacing: 20) {
            if isLocked {
                LockedView(parentAdminPassword: $unusedPassword, showAdminForm: $showAdminForm)
                    .onChange(of: showAdminForm) {
                        withAnimation { isLocked = false }
                    }
            } else {
                HStack(spacing: 30) {
                    ProfileImage()
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Admin: \(adminData.fullName)")
                            .font(.headline)
                        Text("Company Code: \(adminData.companyCode)")
                    }
                    .task {
                        punchsyncfb.loadAdminData(adminData: adminData) { success, error in
                            if success {
                                print("Admin data loaded successfully")
                                fetchCheckedInUsers(for: adminData.companyCode)
                            } else if let error = error {
                                print("Error loading admin data: \(error.localizedDescription)")
                            }
                        }
                    }
                }

                VStack {
                    Text("Active Employees")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "ECE9D4"))
                        .foregroundColor(Color("PrimaryTextColor"))
                        .font(.headline)

                    VStack(spacing: 0) {
                        HStack {
                            Text("Currently checkedIn")
                            Spacer()
                            Text("\(checkedInUsers.count)")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color(hex: "ECE9D4").opacity(0.1))
                    }
                    .font(.body)

                    if !checkedInUsers.isEmpty {
                        List(checkedInUsers) { user in
                            Text(user.fullName)
                        }
                        .frame(height: min(300, CGFloat(checkedInUsers.count) * 150)) // Limit height
                    } else {
                        Text("No users currently checked in.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "ECE9D4"), lineWidth: 1)
                )
                .padding(.vertical)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Stay Informed")
                        .font(.title2)
                        .bold()

                    Text("Stay informed with the latest updates and essential information tailored to your needs.")
                        .font(.body)
                        .foregroundColor(Color("SecondaryTextColor"))
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Button(action: {
                    print("Add New Data")
                }) {
                    HStack {
                        Text("Add New Data")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "8BC5A3"))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .padding()
        Spacer().frame(height: 100)
    }
}

#Preview {
    DashboardTabView(isLocked: .constant(false))
}
