//
//  CompanyView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2024-12-20.
//

import SwiftUI

struct CompanyView: View {
    @Environment(\.presentationMode) var presentationMode
    // Properties for displaying company data
    @State private var companyName: String = "ABC Company AB" // Bëhet modifikues
    let organisationNumber: String = "123456-7890"
    let workplace: String = "Headquarters, Stockholm"
    let connectionStatus: String = "Online"
    let pendingEvents: Int = 5
    let companyID: String = "COMP-001"
    
    var body: some View {
        NavigationView {
                    VStack {
                        // Butoni "Back"
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss() // Kthehet mbrapa
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left")
                                        .foregroundColor(.blue)
                                    Text("Back")
                                        .foregroundColor(.blue)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        
                        // Tabela për të dhënat e kompanisë
                        Form {
                            Section(header: Text("Company Information")) {
                                HStack {
                                    Text("Company Name:")
                                        .bold()
                                    Spacer()
                                    // TextField për të modifikuar emrin e kompanisë
                                    TextField("Enter Company Name", text: $companyName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: 200) // Kufizojmë gjerësinë
                                }
                                
                                HStack {
                                    Text("Organization Number:")
                                        .bold()
                                    Spacer()
                                    Text(organisationNumber)
                                }
                                
                                HStack {
                                    Text("Workplace:")
                                        .bold()
                                    Spacer()
                                    Text(workplace)
                                }
                            }
                            
                            Section(header: Text("Status")) {
                                HStack {
                                    Text("Connection Status:")
                                        .bold()
                                    Spacer()
                                    Text(connectionStatus)
                                        .foregroundColor(connectionStatus == "Online" ? .green : .red)
                                }
                                
                                HStack {
                                    Text("Number of Events to Send:")
                                        .bold()
                                    Spacer()
                                    Text("\(pendingEvents)")
                                }
                            }
                            
                            Section(header: Text("Identifiers")) {
                                HStack {
                                    Text("Company ID:")
                                        .bold()
                                    Spacer()
                                    Text(companyID)
                                }
                            }
                        }
                
                // Button for saving changes
                Button(action: {
                    // Logic for saving the changes
                    print("Company Name Updated to: \(companyName)")
                }) {
                    Text("Save Changes")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color(hex: "FD9709")) // Stili ekzistues i butonit
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    CompanyView()
}
