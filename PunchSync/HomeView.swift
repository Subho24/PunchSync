//
//  HomeView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI
import Firebase

struct HomeView: View {
    
    @State var punchsyncfb = PunchSyncFB()
    
    init() {
        // This ensures that the TabBar has the correct background color
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "#E0E2C1")
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
      var body: some View {
          
          HStack {
                      Spacer()
                      Button(action: {
                          punchsyncfb.userLogout()
                      }) {
                          Text("Sign out")
                              .font(.headline)
                              .foregroundColor(.red)
                              .padding(.horizontal, 10)
                              .padding(.vertical, 5)
                              .background(Color(hex: "ECE9D4"))
                              .cornerRadius(10)
                      }
                  }
          
          TabView {
              // Dashboard Tab
              VStack {
                  DashboardTabView()
              }
              .tabItem {
                VStack {
                  Image(systemName: "tray.2.fill")
                  Text("Dashboard")
                }
              }
              // Check In / Out Tab
              VStack {
                Check_in_out()
              }
              .tabItem {
                VStack {
                  Image(systemName: "clock")
                  Text("Check In / Out")
                }
              }
              // More Tab
              VStack {
              MoreTabView()
              }
              .tabItem {
                VStack {
                  Image(systemName: "list.dash")
                  Text("More")
                }
              }
            }
           .accentColor(Color.black) // Active Tab
          }
        }

    extension UIColor {
      // Function to convert HEX color to UIColor
      convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
      }
}

#Preview {
    HomeView()
}
