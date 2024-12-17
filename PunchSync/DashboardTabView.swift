//
//  DashboardTabView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI
import Firebase

struct DashboardTabView: View {
 
    var body: some View {
        VStack(spacing: 20) {
        
            // Profile Section
            HStack(spacing: 50) {
                Circle()
                    .fill(Color(hex: "ECE9D4"))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(radius: 5)
                    .padding(.bottom, 5)
               
                VStack{
                    Text("Name Lastname")
                        .font(.title3)
                        .foregroundColor(.black)
                    Text("Position")
                        .foregroundColor(.gray)
                }
            }
            
            // Shift Details Table
            VStack(spacing: 0) {
                Text("Shift Details")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "ECE9D4"))
                    .font(.headline)
                
                // Table Content
                VStack(spacing: 0) {
                    HStack {
                        Text("Shift 1")
                        Spacer()
                        Text("12")
                        Spacer()
                        Text("5")
                        Spacer()
                        Text("8")
                    }
                    .padding()
                    .background(Color(hex: "ECE9D4").opacity(0.1))
                    Divider()
                    
                    HStack {
                        Text("Shift 2")
                        Spacer()
                        Text("20")
                        Spacer()
                        Text("3")
                        Spacer()
                        Text("28")
                    }
                    .padding()
                    Divider()
                    
                    HStack {
                        Text("Shift 3")
                        Spacer()
                        Text("9")
                        Spacer()
                        Text("4")
                        Spacer()
                        Text("30")
                    }
                    .padding()
                    .background(Color(hex: "ECE9D4").opacity(0.1))
                }
                .font(.body)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "ECE9D4"), lineWidth: 1)
            )
            .padding()
            
            // Title and Text Content
            VStack(alignment: .leading, spacing: 10) {
                Text("Tittle text")
                    .font(.title2)
                    .bold()
                
                Text("Stay informed with the latest updates and essential information tailored to your needs.")
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            
            // Dashboard Button
                                Button(action: {
                                    print("Dashboard button")
                                }) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 30, height: 30)

                                            Image(systemName: "tray.2.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 17, height: 17)
                                                .foregroundColor(.black)
                                        }
                                        .padding(.leading, 10)

                                        Text("Dashboard")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "8BC5A3"))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                        
                        //Dashboard Button slut
                        
                        
                        //Test Button
                        Button(action: {
                            print("Test button")
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 30, height: 30)
                                    .padding(.leading, 10)
                                
                                Text("Test ")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "F5C87E"))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        //Test Button slut
        }
    }
}
#Preview {
  DashboardTabView()
}
