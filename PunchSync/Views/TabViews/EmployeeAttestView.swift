import SwiftUI
import Firebase
import FirebaseAuth

class EmployeeAttestViewModel: ObservableObject { // Make AttestView conform to ObservableObject

    @Published var isChecked: Bool = false
    @Published var earliestPunchDate: String = ""
    @Published var allDatesArray: [Date] = []
    @Published var allAttestData: [String: [String: [[String: String]]]] = [:]
    @Published var punchRecords: [String: Any] = [:]
    @Published var companyCode: String?
    @Published var currUserPersonalNumber: String?

    
    
    // MARK: - Helper Methods
    
    func fetchCompanyCode() {
        guard let currentAdminId = Auth.auth().currentUser?.uid else {
            print("No admin is logged in")
            return
        }
        
        getCompanyCode(currentAdminId) { companyCode in
            DispatchQueue.main.async {
                self.companyCode = companyCode
            }
        }
    }

    
    func getCompanyCode(_ userId: String, completion: @escaping (String?) -> Void) {
        let ref = Database.database().reference()

        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any],
               let companyCode = value["companyCode"] as? String {
                completion(companyCode)
                print(companyCode)
            } else {
                completion(nil) // Return nil if companyCode is not found
            }
        }
    }
    
    
    func fetchPersonalNumber() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No admin is logged in")
            return
        }
        
        getCurrUserPersonalNumber(currentUserId) { personalNumber in
            DispatchQueue.main.async {
                self.currUserPersonalNumber = personalNumber
            }
        }
    }
    
    func getCurrUserPersonalNumber(_ userId: String, completion: @escaping (String?) -> Void) {
        let ref = Database.database().reference()

        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any],
               let personalNumber = value["personalSecurityNumber"] as? String {
                completion(personalNumber)
                print(personalNumber)
            } else {
                completion(nil) // Return nil if companyCode is not found
            }
        }
    }

    
    func generateDateArray(from startDateString: String, punchRecords: [String: Any]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let startDate = dateFormatter.date(from: startDateString) else { return }
        
        let calendar = Calendar.current
        var dates: [Date] = []
        var current = startDate
        let currentDate = Date()
        
        while current <= currentDate {
            dates.append(current)
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: current) {
                current = nextDay
            } else {
                break
            }
        }
        
        var attestData: [String: [String: [[String: String]]]] = [:]
        
        // Fetch user data from Firebase
        fetchUserData { userFullNames in
            // Process punchRecords and add fullName
            self.processPunchRecords(punchRecords, userFullNames: userFullNames, attestData: &attestData)
            
            // Update state variables on the main thread
            DispatchQueue.main.async {
                self.allDatesArray = dates
                self.allAttestData = attestData
            }
        }
    }

    func fetchUserData(completion: @escaping ([String: String]) -> Void) {
        var userFullNames: [String: String] = [:]
        
        let ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                for (_, userData) in value {
                    if let userDict = userData as? [String: Any],
                       let personNumber = userDict["personalSecurityNumber"] as? String,
                       let fullName = userDict["fullName"] as? String {
                        // Store mapping of personalNumber -> fullName
                        userFullNames[personNumber] = fullName
                    }
                }
            }
            completion(userFullNames)
        }
    }

    func processPunchRecords(_ punchRecords: [String: Any], userFullNames: [String: String], attestData: inout [String: [String: [[String: String]]]]) {
        for (userId, records) in punchRecords {
            if let userRecords = records as? [String: Any] {
                for (date, punches) in userRecords {
                    if attestData[date] == nil {
                        attestData[date] = [:]
                    }
                    
                    let fullName = userFullNames[ValidationUtils.formatPersonalNumber(userId)] ?? "Unknown"
                    
                    if let punchDetails = punches as? [String: String] {
                        var punchData = punchDetails
                        punchData["fullName"] = fullName // Add fullName
                        punchData["userId"] = userId
                        attestData[date]?[userId] = [punchData]
                    } else if let punchList = punches as? [[String: String]] {
                        var updatedPunchList = punchList.map { punch in
                            var newPunch = punch
                            newPunch["fullName"] = fullName // Add fullName
                            newPunch["userId"] = userId
                            return newPunch
                        }
                        attestData[date]?[userId] = updatedPunchList
                    }
                }
            }
        }
    }

    func getEarliestPunchDate(completion: @escaping (String?) -> Void) {
        let ref = Database.database().reference().child("punch_records")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any] {
                self.punchRecords = value
            }
            
            var dates: [String] = []
            
            for (userId, userData) in self.punchRecords {
                if let userPunchData = userData as? [String: Any] {
                    for (date, _) in userPunchData {
                        dates.append(date)
                    }
                }
            }
            
            let earliestDate = dates.sorted().first
            completion(earliestDate)
        }
    }
    
    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    func convertStringToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

struct EmployeeAttestView: View {

    @StateObject var viewModel = EmployeeAttestViewModel()  // Use @StateObject to initialize the ViewModel
    
    // MARK: - User Interface Components

    var body: some View {
        VStack {
            EmployeeAttestHeaderView()
            
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(viewModel.allDatesArray, id: \.self) { dateString in
                        EmployeeDateAttestSection(dateString: viewModel.convertDateToString(date: dateString))
                    }
                    
                    Color.clear.frame(height: 1).id("bottom")
                }.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
                .padding(.bottom, 80)
            }

        }
        .onAppear {
            viewModel.getEarliestPunchDate { earliestDate in
                if let date = earliestDate {
                    viewModel.earliestPunchDate = date
                    print("Earliest Punch Record Date: \(date)")
                    viewModel.generateDateArray(from: date, punchRecords: viewModel.punchRecords)
                } else {
                    print("No date")
                }
            }
            
            viewModel.fetchCompanyCode()
            viewModel.fetchPersonalNumber()
        }
        .ignoresSafeArea()
        .environmentObject(viewModel)  // Pass the ViewModel to the environment
        .onAppear {
            guard let currentAdmin = Auth.auth().currentUser else {
                print("No admin is currently logged in")
                return
            }
            print((Auth.auth().currentUser?.uid)!)
        }
    }
}

// MARK: - Custom Components

struct EmployeeAttestHeaderView: View {
    var body: some View {
        VStack {
            Text("Attests")
                .font(.title)
                .bold()
        }
        //.padding(.top, 50)
        //.padding(.leading, 30)
        .frame(maxWidth: .infinity, minHeight: 80)
        //.background(Color(hex: "ECE9D4"))
    }
}

struct EmployeeDateAttestSection: View {
    var dateString: String
    @EnvironmentObject var viewModel: EmployeeAttestViewModel  // Get ViewModel

    var body: some View {
        VStack {
            HStack {
                Text(dateString)
                Spacer()
            }
            .padding()

            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .foregroundColor(.black)

            if let attestDataForDate = viewModel.allAttestData[dateString] {
                let filteredRecords = attestDataForDate.flatMap { (userId, userAttestList) in
                    userAttestList.filter { userAttestData in
                        userAttestData["companyCode"] == viewModel.companyCode // Match companyCode
                        && ValidationUtils.formatPersonalNumber(userAttestData["userId"]!) == viewModel.currUserPersonalNumber // Match userId with currUserPersonalNumber

                    }
                }
                

                if !filteredRecords.isEmpty {
                    ForEach(attestDataForDate.keys.sorted(), id: \.self) { userId in
                        if let userAttestList = attestDataForDate[userId] {
                            ForEach(userAttestList.indices, id: \.self) { index in
                                if userAttestList[index]["companyCode"] == viewModel.companyCode, ValidationUtils.formatPersonalNumber(userAttestList[index]["userId"]!) == viewModel.currUserPersonalNumber {
                                    EmployeeAttestRecordView(userAttestData: userAttestList[index])
                                }
                            }
                        }
                    }
                } else {
                    Text("No records for this date") // Show message when no matching records
                        .foregroundColor(.gray)
                        .padding()
                }
            } else {
                Text("No records for this date") // Also show message when no data exists
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding(.vertical)
    }
}


struct EmployeeAttestRecordView: View {
    var userAttestData: [String: String]
    @State private var isChecked: Bool = false
    @EnvironmentObject var viewModel: EmployeeAttestViewModel  // Get the ViewModel from the environment
    

    // The function that will toggle the approval and save it to Firebase
    func toggleApproval() {
        guard let checkInTime = userAttestData["checkInTime"],
              let userId = userAttestData["userId"],
              let checkOutTime = userAttestData["checkOutTime"] else {
            print("Missing required data")
            return
        }

        let dateString = checkInTime.split(separator: " ")[0]

        let ref = Database.database().reference().child("punch_records").child(userId).child(String(dateString))

        ref.observeSingleEvent(of: .value) { snapshot in
            print("Snapshot value: \(snapshot.value ?? "nil")") // Debugging line

            // Check if the snapshot contains an array of records
            if let recordsArray = snapshot.value as? [[String: Any]] {
                // Handle the array structure
                if var record = recordsArray.first {
                    // Toggle the approval status
                    if let approved = record["approved"] as? String, approved == "true" {
                        record["approved"] = "false"
                    } else {
                        record["approved"] = "true"
                    }

                    // Save the updated record
                    ref.child("0").updateChildValues(record) { error, _ in
                        if let error = error {
                            print("Error updating approval: \(error.localizedDescription)")
                        } else {
                            print("Approval toggled successfully!")
                            isChecked.toggle() // Toggle the local state as well
                        }
                    }
                }
            }
            // Check if the snapshot contains a dictionary (non-array structure)
            else if var record = snapshot.value as? [String: Any] {
                // Handle the dictionary structure (flat record)
                // Toggle the approval status
                if let approved = record["approved"] as? String, approved == "true" {
                    record["approved"] = "false"
                } else {
                    record["approved"] = "true"
                }

                // Save the updated record
                ref.updateChildValues(record) { error, _ in
                    if let error = error {
                        print("Error updating approval: \(error.localizedDescription)")
                    } else {
                        print("Approval toggled successfully!")
                        isChecked.toggle() // Toggle the local state as well
                    }
                }
            } else {
                print("No record found or invalid data structure")
            }
        }
    }










    var body: some View {
        VStack {
            Rectangle()
                .fill(Color(hex: "8BC5A3"))
                .frame(height: 80)
                .cornerRadius(20)
                .overlay(
                    HStack {
                        VStack(alignment: .leading) {
                            Text(userAttestData["fullName"] ?? "Unknown")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .bold()
                            
                            
                            if let breakStartTime = userAttestData["breakStartTime"], !breakStartTime.isEmpty, let breakEndTime = userAttestData["breakEndTime"], !breakEndTime.isEmpty {
                                
                                
                                HStack {
                                    if let checkInTime = userAttestData["checkInTime"],
                                       let checkInComponents = checkInTime.split(separator: " ").last {
                                        Text(String(checkInComponents))
                                    }
                                    

                                    if let breakStartTime = userAttestData["breakStartTime"],
                                       let breakStartComponents = breakStartTime.split(separator: " ").last {
                                        Text(String(breakStartComponents))
                                    }
                                    
                                }
                                
                                HStack {
                                    if let breakEndTime = userAttestData["breakEndTime"],
                                       let breakEndComponents = breakEndTime.split(separator: " ").last {
                                        Text(String(breakEndComponents))
                                    }
                                    

                                    if let checkOutTime = userAttestData["checkOutTime"],
                                       let checkOutComponents = checkOutTime.split(separator: " ").last {
                                        Text(String(checkOutComponents))
                                    }
                                    
                                }
                                
                                
                            } else {
                                
                                
                                HStack {
                                    if let checkInTime = userAttestData["checkInTime"],
                                       let checkInComponents = checkInTime.split(separator: " ").last {
                                        Text(String(checkInComponents))
                                    } else {
                                        Text("Invalid Check-In Time")
                                    }
                                    

                                    if let checkOutTime = userAttestData["checkOutTime"],
                                       let checkOutComponents = checkOutTime.split(separator: " ").last {
                                        Text(String(checkOutComponents))
                                    } else {
                                        Text("Invalid Check-Out Time")
                                    }
                                }
                            }
                            
                        }
                        .padding(20)
                        Spacer()
                        Button(action: {
                            toggleApproval()  // Call the function to toggle the approval status
                        }) {
                            Image(systemName: isChecked ? "checkmark.square.fill" : "circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(isChecked ? Color(hex: "36906B") : Color.black)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .disabled(true)
                        .padding(20)
                    }
                )
        }
        .padding([.leading, .trailing], 10)
        .onAppear {
            // If already approved, set the initial state to checked
            if let approved = userAttestData["approved"], approved == "true" {
                isChecked = true
            }
            print(userAttestData, "here")
        }
    }
}


#Preview {
    EmployeeAttestView()
}
