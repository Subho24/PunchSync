import SwiftUI
import Firebase
import FirebaseAuth

struct Check_in_out: View {
    
    @State private var userInput: String = ""
    @State private var checkInAlert = false
    @State private var checkOutAlert = false
    @State private var breakStartAlert = false
    @State private var breakEndAlert = false
    @State private var showButtons = false
    @State private var checkedIn = false
    @State private var inBreak = false
    @State private var userValidated = false
    @State private var userNotFoundAlert = false
    @State private var currCompanyCode : String = ""
    @State private var invalidUserAlertMessage: String = "Personal-Number not registered. Try to check in as a guest"
    
    @Binding var isLocked: Bool
    
    
    var punchRecords: [String: Any] = [:]
    
    let numberPad: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["C", "0", "⌫"]
    ]
    
    
    func handleInput(_ item: String) {
        if item == "C" {
            userInput = "" // Clear the user input
            resetView()
        } else if item == "⌫" {
            userInput = String(userInput.dropLast()) // Remove the last character
        } else {
            userInput += item // Add the input
        }
    }
    
    func getCompanyCode(_ userId: String, completion: @escaping (String?) -> Void) {
        let ref = Database.database().reference()

        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            if let value = snapshot.value as? [String: Any],
               let companyCode = value["companyCode"] as? String {
                completion(companyCode)
            } else {
                completion(nil) // Return nil if companyCode is not found
            }
        }
    }

    
    func resetView() {
        userInput = ""
        checkInAlert = false
        checkOutAlert = false
        breakStartAlert = false
        breakEndAlert = false
        showButtons = false
        checkedIn = false
        inBreak = false
        userValidated = false
        invalidUserAlertMessage = "Personal-Number not registered. Try to check in as a guest"
    }
    
    func validateUser(_ personalNumber: String, completion: @escaping () -> Void) {
        let ref = Database.database().reference()

        ref.child("users").observeSingleEvent(of: .value) { snapshot in

            var userFound = false

            // Loop through all users
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let userData = childSnapshot.value as? [String: Any],
                   let securityNumber = userData["personalSecurityNumber"] as? String,
                   securityNumber == ValidationUtils.formatPersonalNumber(personalNumber) {

                    userValidated = true
                    userFound = true
                    break
                }
            }

            if !userFound {
                userNotFoundAlert = true
            }

            // Call the completion handler once the async task is done
            completion()
        }
    }

       
    func handlePunch(_ personalNumber: String) {
        var ref: DatabaseReference
        
        ref = Database.database().reference()
        
        var newUserData: [String: Any] = [:]
        let currentTimestamp = Int64(Date().timeIntervalSince1970 * 1000) // in milliseconds
        var lastPunchType: String?
        
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let userData = childSnapshot.value as? [String: Any],
                   let securityNumber = userData["personalSecurityNumber"] as? String,
                   securityNumber == ValidationUtils.formatPersonalNumber(personalNumber) {

                    userValidated = true
                    
                    newUserData = userData
                    
                    if(userData["punches"] == nil) {
                        newUserData["punches"] = [
                            [
                                "type": "CheckIn",
                                "time": currentTimestamp
                            ]
                        ]
                        return //Check i user for the first time after registration
                    }
                    
                    if let punches = userData["punches"] as? [[String: Any]],
                       let lastPunch = punches.last,
                       let punchType = lastPunch["type"] as? String {
                        if punchType == "CheckIn" {
                            checkedIn = true
                        } else if punchType == "CheckOut" {
                            checkedIn = false
                        }
                        lastPunchType = punchType
                    }
                    
                    //ref.child("users").child(childSnapshot.key).setValue(newUserData)
                    break
                }
            }
            
            
        }
        
        
        
        
    }
        
    func fixPunchRecord(_ punchDetails: inout [String: String]) -> [String: String] {
            print(punchDetails, "here is the punchDetails")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            // Ensure `checkInTime` exists and parse it
            guard let checkInTimeString = punchDetails["checkInTime"]?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let checkInTime = dateFormatter.date(from: checkInTimeString)
            else {
                return [:]
            }
            
            // Set `checkOutTime` to the same date at 23:59 if missing
            if punchDetails["checkOutTime"]?.isEmpty ?? true {
                let calendar = Calendar.current
                if let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 0, of: checkInTime) {
                    punchDetails["checkOutTime"] = dateFormatter.string(from: endOfDay)
                }
            }
            
            // Check and update `breakEndTime` based on `breakStartTime`
            if let breakStartTimeString = punchDetails["breakStartTime"],
               !breakStartTimeString.isEmpty,
               let breakStartTime = dateFormatter.date(from: breakStartTimeString) {
                let breakEndTime = breakStartTime.addingTimeInterval(30 * 60) // Add 30 minutes
                punchDetails["breakEndTime"] = dateFormatter.string(from: breakEndTime)
            }
            
            print(punchDetails, "here is the fixed punchDetails")
            return punchDetails
        }
        
    func checkInUser(_ personalNummer: String) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let currentDateString = dateFormatter.string(from: Date())
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
        let currentDateTimeString = dateTimeFormatter.string(from: Date())
        
        
        let punchData: [String: String] = [
            "checkInTime": currentDateTimeString,
            "checkOutTime": "",
            "breakStartTime":  "",
            "breakEndTime": "",
            "approved": "false",
            "companyCode": currCompanyCode,
            
        ]
        
        // Reference to the user's punch record for the current date
        let punchRecordRef = ref.child("punch_records").child(personalNummer).child(currentDateString)
        
        // Get the existing data for the current date
        punchRecordRef.observeSingleEvent(of: .value) { snapshot in
            if var existingData = snapshot.value as? [[String: String]] {
                // If it's an array, just append the new punch record
                existingData.append(punchData)
                punchRecordRef.setValue(existingData)
            } else if let existingRecord = snapshot.value as? [String: String] {
                // If it's a single record, convert it into an array and append the new record
                let punchRecordsArray = [existingRecord, punchData]
                punchRecordRef.setValue(punchRecordsArray)
            } else {
                // If no data exists for the date, initialize with the first punch record
                punchRecordRef.setValue([punchData])
            }
        }
    }



        
    func checkOutUser(_ personalNummer: String) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let currentDateString = dateFormatter.string(from: Date())
        
        // Check if a punch record exists for the user for today
        ref.child("punch_records").child(personalNummer).child(currentDateString).observeSingleEvent(of: .value) { snapshot in
            if let recordArray = snapshot.value as? [[String: String]] {
                // Data is an array, get the last record
                if let lastRecord = recordArray.last, lastRecord["checkOutTime"] == "" && lastRecord["checkInTime"] != "" {
                    let dateTimeFormatter = DateFormatter()
                    dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
                    let currentDateTimeString = dateTimeFormatter.string(from: Date())
                    
                    // Update the checkOutTime for the last record in the array
                    var updatedRecord = lastRecord
                    updatedRecord["checkOutTime"] = currentDateTimeString
                    
                    // Get the index of the last record
                    if let lastIndex = recordArray.firstIndex(where: { $0 == lastRecord }) {
                        var updatedRecordArray = recordArray
                        updatedRecordArray[lastIndex] = updatedRecord
                        
                        // Update the database with the updated array
                        ref.child("punch_records").child(personalNummer).child(currentDateString).setValue(updatedRecordArray)
                        
                    }
                } else {
                }
            } else if let record = snapshot.value as? [String: String] {
                // Data is a single record, handle it as before
                if let checkInTime = record["checkInTime"], checkInTime != "", let checkOutTime = record["checkOutTime"], checkOutTime == "" {
                    let dateTimeFormatter = DateFormatter()
                    dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
                    let currentDateTimeString = dateTimeFormatter.string(from: Date())
                    
                    // Update the checkOutTime for the single record
                    var updatedRecord = record
                    updatedRecord["checkOutTime"] = currentDateTimeString
                    
                    // Update the database with the updated record
                    ref.child("punch_records").child(personalNummer).child(currentDateString).setValue(updatedRecord)
                    
                    print("User with personal number \(personalNummer) has checked out at \(currentDateTimeString).")
                } else {
                    print("User with personal number \(personalNummer) has already checked out today.")
                }
            } else {
                print("No check-in record found for user with personal number \(personalNummer) on \(currentDateString).")
            }
        }
    }

        
    func updateBreakTime(_ personalNummer: String, _ breakAction: String) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let currentDateString = dateFormatter.string(from: Date())
        
        // Check if a punch record exists for the user for today
        ref.child("punch_records").child(personalNummer).child(currentDateString).observeSingleEvent(of: .value) { snapshot in
            if var existingData = snapshot.value as? [[String: String]] {
                // If data is an array, update the last record in the array
                var latestRecord = existingData.last ?? [:]
                
                if let checkInTime = latestRecord["checkInTime"], !checkInTime.isEmpty {
                    
                    // Proceed with updating the break time
                    let dateTimeFormatter = DateFormatter()
                    dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    dateTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
                    let currentDateTimeString = dateTimeFormatter.string(from: Date())
                    
                    if breakAction == "start" {
                        // Update breakStartTime if it's not already set
                        if latestRecord["breakStartTime"]?.isEmpty ?? true {
                            latestRecord["breakStartTime"] = currentDateTimeString
                            print("User \(personalNummer) started a break at \(currentDateTimeString).")
                        } else {
                            print("User \(personalNummer) has already started a break.")
                        }
                    } else if breakAction == "end" {
                        // Update breakEndTime if breakStartTime is already set and breakEndTime is empty
                        if let breakStartTime = latestRecord["breakStartTime"], !breakStartTime.isEmpty,
                           latestRecord["breakEndTime"]?.isEmpty ?? true {
                            latestRecord["breakEndTime"] = currentDateTimeString
                            print("User \(personalNummer) ended their break at \(currentDateTimeString).")
                        } else {
                            print("User \(personalNummer) has already ended their break or hasn't started one.")
                        }
                    } else {
                        print("Invalid break action: \(breakAction). Use 'start' or 'end'.")
                        return
                    }
                    
                    // Replace the last record with the updated record
                    existingData[existingData.count - 1] = latestRecord
                    
                    // Update the database with the updated array of records
                    ref.child("punch_records").child(personalNummer).child(currentDateString).setValue(existingData)
                } else {
                    print("No valid check-in record found for user \(personalNummer) on \(currentDateString).")
                }
            } else if let existingRecord = snapshot.value as? [String: String] {
                // If it's a single dictionary, convert it into an array and update it
                var updatedRecord = existingRecord
                let dateTimeFormatter = DateFormatter()
                dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
                let currentDateTimeString = dateTimeFormatter.string(from: Date())
                
                if breakAction == "start" {
                    // Update breakStartTime if it's not already set
                    if updatedRecord["breakStartTime"]?.isEmpty ?? true {
                        updatedRecord["breakStartTime"] = currentDateTimeString
                        print("User \(personalNummer) started a break at \(currentDateTimeString).")
                    } else {
                        print("User \(personalNummer) has already started a break.")
                    }
                } else if breakAction == "end" {
                    // Update breakEndTime if breakStartTime is already set and breakEndTime is empty
                    if let breakStartTime = updatedRecord["breakStartTime"], !breakStartTime.isEmpty,
                       updatedRecord["breakEndTime"]?.isEmpty ?? true {
                        updatedRecord["breakEndTime"] = currentDateTimeString
                        print("User \(personalNummer) ended their break at \(currentDateTimeString).")
                    } else {
                        print("User \(personalNummer) has already ended their break or hasn't started one.")
                    }
                } else {
                    print("Invalid break action: \(breakAction). Use 'start' or 'end'.")
                    return
                }
                
                // Set the data as an array of one record
                ref.child("punch_records").child(personalNummer).child(currentDateString).setValue([updatedRecord])
            } else {
                print("No check-in record found for user with personal number \(personalNummer) on \(currentDateString), or the user is not checked in.")
            }
        }
    }

        
        
        
        func isTimeWithin12Hours(_ time: String, _ timeToCheck: String) -> Bool {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust format to match your input
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            // Convert checkInTime string to Date object
            guard let checkInDate = dateFormatter.date(from: time) else {
                print("Invalid date format.")
                return false
            }
            
            // Get the current date
            let currentDate = Date()
            
            // Calculate the time difference in seconds
            let timeDifference = currentDate.timeIntervalSince(checkInDate)
            
            // Check if the time difference is within 12 hours (12 * 60 * 60 seconds) or 30 minutes (30 * 60)
            
            if timeToCheck == "break" {
                return timeDifference <= 30 * 60
            }
            
            return timeDifference <= 12 * 60 * 60
        }
        
    func getPunchStatusAndFix(_ personalNumber: String) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let currentDateString = dateFormatter.string(from: Date())
        
        // Fetch all punch records for the user
        ref.child("punch_records").child(personalNumber).observeSingleEvent(of: .value) { snapshot  in
            guard let records = snapshot.value as? [String: Any] else {
                print("No records found for user \(personalNumber).")
                return
            }
            
            var isTodayCheckedIn = false
            
            for (date, record) in records {
                // Check if the data is an array or a single record
                if let recordArray = record as? [[String: String]] {
                    // If the data is an array, check and update the last record in the array
                    if let lastRecord = recordArray.last {
                        var punchData = lastRecord
                        
                        // Fix invalid records
                        if let checkInTime = lastRecord["checkInTime"], !isTimeWithin12Hours(checkInTime, "CheckIn") {
                            let fixedPunchData = fixPunchRecord(&punchData)  // Get corrected data
                            
                            // Update only the fixed record in Firebase
                            let lastIndex = recordArray.count - 1
                            let recordPath = "/punch_records/\(personalNumber)/\(date)/\(lastIndex)"
                            print(recordPath)
                            ref.child(recordPath).updateChildValues(fixedPunchData)
                        }
                        
                        // Update the database with the fixed record
                        // ref.child("punch_records").child(personalNumber).child(date).setValue(recordArray)
                        
                        // Check if the user is checked in today
                        if date == currentDateString {
                            isTodayCheckedIn = true
                            
                            if lastRecord["checkOutTime"] == "" {
                                checkedIn = true
                            }
                            
                            if lastRecord["breakStartTime"] != "" && lastRecord["breakEndTime"] == "" {
                                inBreak = true
                            }
                        }
                    }
                } else if let record = record as? [String: String] {
                    // If the data is a single record, handle it as before
                    var punchData = record
                    
                    // Fix invalid records
                    if let checkInTime = record["checkInTime"], !isTimeWithin12Hours(checkInTime, "CheckIn") {
                        fixPunchRecord(&punchData)
                    }
                    
                    // Update the database with the fixed record
                    ref.child("punch_records").child(personalNumber).child(date).setValue(punchData)
                    
                    // Check if the user is checked in today
                    if date == currentDateString {
                        isTodayCheckedIn = true
                        
                        if record["checkOutTime"] == "" {
                            checkedIn = true
                        }
                        
                        if record["breakStartTime"] != "" && record["breakEndTime"] == "" {
                            inBreak = true
                        }
                    }
                }
            }
            
            // If no check-in for today, create a new record
            /*if !isTodayCheckedIn {
                let punchData: [String: String] = [
                    "checkInTime": dateTimeFormatter.string(from: Date()),
                    "checkOutTime": "",
                    "breakStartTime": "",
                    "breakEndTime": ""
                ]
                ref.child("punch_records").child(personalNumber).child(currentDateString).setValue([punchData])
                checkedIn = true
                inBreak = false
            }*/
        }
    }

        
        
        var body: some View {
            ZStack {
                VStack {
                    HStack {
                        Button(action: {
                            isLocked = true
                        }) {
                            Text(isLocked ? "Locked" : "Lock")
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                        Image(systemName: "lock")
                        Spacer()
                    }
                    .padding(20)
                    
                    Spacer()
                }
                VStack(spacing: 10) {
                    Text("Personal Number")
                        .font(.title)
                        .padding(30)
                    Text(userInput.isEmpty ? "YYYYMMDD-XXXX" : userInput)
                        .font(.title)
                        .opacity(userInput.isEmpty ? 0.3 : 1)
                    Rectangle()
                        .frame(width: 300, height: 1)
                        .foregroundColor(.black)
                        .padding(.bottom, 30)
                    ForEach(numberPad, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(row, id: \.self) { item in
                                Button(action: {
                                    handleInput(item)
                                }) {
                                    Text(item)
                                        .font(.title)
                                        .frame(width: 70, height: 70)
                                        .background(Color.gray.opacity(item.isEmpty ? 0 : 0.4))
                                        .foregroundColor(.black)
                                        .cornerRadius(10)
                                }
                                .disabled(item.isEmpty) // Disable empty buttons
                            }
                        }
                    }
                    
                    
                    
                    if(!showButtons) {
                        Button(action: {
                            // Your button action here
                            if !userInput.isEmpty && !ValidationUtils.isValidPersonalNumber(userInput) {
                                
                                invalidUserAlertMessage = "Invalid personal number"
                                
                                userNotFoundAlert = true
                            }
                            print("pressed next")
                            if !userInput.isEmpty && ValidationUtils.isValidPersonalNumber(userInput) {
                                validateUser(userInput) {
                                    if(userValidated) {
                                        showButtons = true
                                        getPunchStatusAndFix(userInput)
                                    }
                                }
                            }
                        }) {
                            ButtonView(buttontext: "Next")
                        }
                        .alert(isPresented: $userNotFoundAlert) {
                            Alert(
                                title: Text("User Not Found"),
                                message: Text(invalidUserAlertMessage),
                                dismissButton: .default(Text("OK"), action: {
                                    resetView()
                                })
                            )
                        }
                    }
                    
                    
                    if showButtons {
                        HStack {
                            Button(action: {
                                checkInUser(userInput)
                                checkInAlert = true
                            }) {
                                ButtonView(buttontext: "Check-In")
                            } //Different alerts variables for each alerts
                            .alert(isPresented: $checkInAlert) {
                                Alert(
                                    title: Text("Checked In"),
                                    message: Text("Good Luck for today!!"),
                                    dismissButton: .default(Text("OK"), action: {
                                        resetView()
                                    })
                                )
                            }
                            .disabled(checkedIn)
                            .opacity(checkedIn ? 0.5 : 1)
                            
                            
                            Button(action: {
                                checkOutUser(userInput)
                                checkOutAlert = true
                            }) {
                                ButtonView(buttontext: "Check-Out")
                            }
                            .alert(isPresented: $checkOutAlert) {
                                Alert(
                                    title: Text("Checked Out"),
                                    message: Text("Great Job!!"),
                                    dismissButton: .default(Text("OK"), action: {
                                        resetView()
                                    })
                                )
                            }
                            .disabled(!checkedIn)
                            .opacity(!checkedIn ? 0.5 : 1)
                        }
                    }
                    if showButtons && checkedIn {
                        HStack {
                            Button(action: {
                                // start break
                                breakStartAlert = true
                                updateBreakTime(userInput, "start")
                            }) {
                                ButtonView(buttontext: "Start break")
                            }
                            .alert(isPresented: $breakStartAlert) {
                                Alert(
                                    title: Text("See you soon!!"),
                                    message: Text("Enjoy Your Break!!"),
                                    dismissButton: .default(Text("OK"), action: {
                                        resetView()
                                    })
                                )
                            }
                            .disabled(inBreak)
                            .opacity(inBreak ? 0.5 : 1)
                            
                            Button(action: {
                                // End break
                                breakEndAlert = true
                                updateBreakTime(userInput, "end")
                            }) {
                                ButtonView(buttontext: "End Break")
                            }
                            .alert(isPresented: $breakEndAlert) {
                                Alert(
                                    title: Text("Welcome Back!!"),
                                    message: Text("Lets get back to Work!!"),
                                    dismissButton: .default(Text("OK"), action: {
                                        resetView()
                                    })
                                )
                            }
                            .disabled(!inBreak)
                            .opacity(!inBreak ? 0.5 : 1)
                        }
                    }
                }
            }
            .onAppear {
                if let currentAdminId = Auth.auth().currentUser?.uid {
                    getCompanyCode(currentAdminId) { companyCode in
                        if let code = companyCode {
                            currCompanyCode = code
                        }
                    }

                } else {
                    print("No admin is currently logged in")
                    return
                }
            }
        }
    
    }

struct Check_in_out_Previews: PreviewProvider {
    static var previews: some View {
        Check_in_out(isLocked: .constant(true))
    }
}
