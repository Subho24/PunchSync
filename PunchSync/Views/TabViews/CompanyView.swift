//
//  CompanyView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

//
//  CompanyView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct CompanyView: View {
    
    @StateObject private var companyDetails = CompanyDetails()
    @State private var newCompanyName: String = ""
    @State private var saveStatusMessage: String = "" 

    var body: some View {
        
        VStack(alignment: .leading, spacing: 20) {
    
        Text("Company Details")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(Color("SecondaryTextColor"))
            .padding(.top, 20)
            .padding(.bottom, 10)
        
            
            // Korniza për Company Code
              HStack {
                  Text("Company Code:")
                      .font(.headline)
                      .foregroundColor(.black)
                  Spacer()
                  Text(companyDetails.companyCode)
                      .font(.body)
                      .foregroundColor(Color("PrimaryTextColor"))
              }
              .padding()
              .background(Color.white)
              .cornerRadius(15) // Radiusi i këndit
              .overlay(RoundedRectangle(cornerRadius: 15)
                          .stroke(Color(hex: "E58D35"), lineWidth: 1)) // Vijë portokalli

              // Korniza për Organization Number
              HStack {
                  Text("Organization Number:")
                      .font(.headline)
                      .foregroundColor(.black)
                  Spacer()
                  Text(companyDetails.orgNumber)
                      .font(.body)
                      .foregroundColor(Color("PrimaryTextColor"))
              }
              .padding()
              .background(Color.white)
              .cornerRadius(15) // Radiusi i këndit
              .overlay(RoundedRectangle(cornerRadius: 15)
              .stroke(Color(hex: "E58D35"), lineWidth: 1))

              
            
            
            
              HStack {Text("Company Name:")
                      .font(.headline)
                      .foregroundColor(Color("SecondaryTextColor"))
                      .padding(.leading, 10) // Përdorim padding për të ndihmuar me distancën

                  Spacer()

                  TextField("Enter New Company Name", text: $newCompanyName)
                        .padding(.vertical)
                        .padding(.leading, 10)
                        .background(Color.white)
                        .foregroundColor(Color("PrimaryTextColor"))
                        .cornerRadius(10)
                        .overlay(
                            HStack {
                                Spacer() // Kjo e shtyn ikonen në të djathtën e fushës
                                Image(systemName: "pencil")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                            }
                        )
                        .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "E58D35"), lineWidth: 1)) // Vijë portokalli për vizualizim më të mirë
                }
            

              // Butoni "Save"
              Button(action: {
                  saveCompanyName()
              }) {
                  Text("Save")
                      .font(.headline)
                      .foregroundColor(.white)
                      .padding()
                      .frame(maxWidth: 200)
                      .background(
                          LinearGradient(
                              gradient: Gradient(colors: [
                                  Color(hex: "FE7E65"),
                                  Color(hex: "E58D35"),
                                  Color(hex: "FD9709")
                              ]),
                              startPoint: .leading,
                              endPoint: .trailing
                          )
                      )
                      .cornerRadius(15)
              }
              .frame(maxWidth: .infinity, alignment: .center) 
        

            // Mesazhi për statusin e ruajtjes
            if !saveStatusMessage.isEmpty {
                Text(saveStatusMessage)
                    .foregroundColor(.green)
                    .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadCompanyDataForCurrentUser { details, error in
                if let details = details {
                    DispatchQueue.main.async {
                        companyDetails.companyCode = details.companyCode
                        companyDetails.orgNumber = details.orgNumber
                        companyDetails.companyName = details.companyName
                        newCompanyName = details.companyName // Vendos emrin aktual si fillestar
                    }
                } else if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Funksioni për të ngarkuar të dhënat e kompanisë
    func loadCompanyDataForCurrentUser(completion: @escaping (CompanyDetails?, Error?) -> Void) {
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else {
            completion(nil, NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in"]))
            return
        }
        let userId = currentUser.uid
        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found"]))
                return
            }
            let currentCompanyCode = userData["companyCode"] as? String ?? ""

            // Kërkojmë të dhënat e kompanisë
            ref.child("companies").observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children {
                    let companySnapshot = child as! DataSnapshot

                    if let companyData = companySnapshot.value as? [String: Any] {
                        let storedCompanyCode = companyData["companyCode"] as? String ?? ""

                        if storedCompanyCode == currentCompanyCode {
                            let details = CompanyDetails()
                            details.companyName = companyData["companyName"] as? String ?? "Unknown Company Name"
                            details.companyCode = storedCompanyCode
                            details.orgNumber = companyData["organizationNumber"] as? String ?? "Unknown Organization Number"

                            completion(details, nil)
                            return
                        }
                    }
                }
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Company not found for the given company code"]))
            }
        }
    }
    
    // Funksioni për të ruajtur emrin e kompanisë
    func saveCompanyName() {
        let ref = Database.database().reference()
        guard let currentUser = Auth.auth().currentUser else {
            saveStatusMessage = "Error: No user is logged in"
            return
        }
        let userId = currentUser.uid
        
        // Merr kodin e kompanisë së përdoruesit
        ref.child("users").child(userId).observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any],
                  let currentCompanyCode = userData["companyCode"] as? String else {
                saveStatusMessage = "Error: Failed to find company code"
                return
            }
            
            // Gjej kompaninë dhe përditëso emrin e saj
            ref.child("companies").observeSingleEvent(of: .value) { snapshot in
                for child in snapshot.children {
                    let companySnapshot = child as! DataSnapshot
                    
                    if let companyData = companySnapshot.value as? [String: Any],
                       let storedCompanyCode = companyData["companyCode"] as? String,
                       storedCompanyCode == currentCompanyCode {
                        
                        // Përditëso emrin e kompanisë
                        ref.child("companies").child(companySnapshot.key).updateChildValues(["companyName": newCompanyName]) { error, _ in
                            if let error = error {
                                saveStatusMessage = "Error saving company name: \(error.localizedDescription)"
                            } else {
                                saveStatusMessage = "Company name saved successfully"
                                companyDetails.companyName = newCompanyName // Përditëso lokalisht
                            }
                        }
                        return
                    }
                }
                saveStatusMessage = "Error: Company not found"
            }
        }
    }
}

#Preview {
    CompanyView()
}
