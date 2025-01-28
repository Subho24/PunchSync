//
//  StatisticView.swift
//  PunchSync
//
//  Created by Arlinda Islami on 2025-01-28.
//

import SwiftUI

struct StatisticView: View {
    // Vlerat e përfaqësuara si barra
    let data: [CGFloat] = [50, 80, 120, 95, 130, 75]
    let labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
    
    
    @State var punchsyncfb = PunchSyncFB()
    @StateObject private var employeeData = EmployeeData(id: "123", data: ["fullName": ""])
 
    var body: some View {
        ScrollView {
            
            VStack {
                HStack(spacing: 50) {
                    ProfileImage()
                    
                    VStack {
                        Text("\(employeeData.fullName)")
                            .font(.headline)
                    }
                    .task {
                        punchsyncfb.loadEmployeeData(employeeData:  employeeData) { success, error in
                            if success {
                                print("Employee data loaded successfully")
                            } else if let error = error {
                                print("Error loading admin data: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 50)
            
            VStack(alignment: .leading, spacing: 30) {
                // Titulli për seksionin e statistikes
                Text("Company Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                    .padding(.horizontal)
                
                // Përshkrimi i statistikave
                Text("This chart shows the performance of key metrics for the company over the last few months. Data is represented by bar heights, and the percentages correspond to monthly performance.")
                    .font(.body)
                    .padding(.bottom, 20)
                    .padding(.horizontal)
                
                // Grafiku me dizajn të thjeshtë
                HStack(alignment: .bottom, spacing: 20) {
                    ForEach(0..<data.count, id: \.self) { index in
                        VStack {
                            // Bar chart pa kartë dhe hije
                            Rectangle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "FE7E65"), Color(hex: "FD9709")]), startPoint: .top, endPoint: .bottom))
                                .frame(width: 40, height: data[index])
                                .cornerRadius(10)

                            // Etiketa për muajin
                            Text(labels[index])
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Shtimi i përqindjeve dhe vijave horizontale
                HStack {
                    ForEach(data, id: \.self) { value in
                        VStack {
                            Text("\(Int(value))%")
                                .font(.caption)
                                .foregroundColor(.black)
                            Divider()
                                .background(Color.gray.opacity(0.3))
                        }
                    }
                }
                .padding(.horizontal)
            
            }
        }
    }
}

#Preview {
    StatisticView()
}
