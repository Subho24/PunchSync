//
//  HomeView.swift
//  PunchSync
//
//  Created by Katya Durneva Svedmark on 2024-12-13.
//

import SwiftUI
import Firebase

struct HomeView: View {
    var isAdmin: Bool
    
    @State var punchsyncfb = PunchSyncFB()
    @State private var isLocked: Bool = false
    @State private var isReady: Bool = false
    @State var showingSignOutAlert = false
    
    
    init(isAdmin: Bool) {
        
        self.isAdmin = isAdmin
         let appearance = UITabBarAppearance()
         appearance.backgroundColor = UIColor(Color(hex: "B5D8C3")) // Ngjyra pastel blu për sfondin
         
         // Ngjyra për tab-et jo aktive
         appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: "FFFFFF")) // Gri e zbehtë për ikonat jo aktive
         appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
             .foregroundColor: UIColor(Color(hex: "FFFFFF")) // Gri e zbehtë për tekstin jo aktiv
         ]
         UITabBar.appearance().standardAppearance = appearance
         if #available(iOS 15.0, *) {
             UITabBar.appearance().scrollEdgeAppearance = appearance
         }
     }

    var body: some View {
        
        if !isReady {
            ProgressView("Loading...")
                .onAppear {
                    // Small delay to ensure state is ready
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isReady = true
                    }
                }
        } else {
            
            HStack {
                Spacer()
                    .frame(width: 330)
                Button(action: {
                    showingSignOutAlert = true
                }) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .padding(10)
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
                        .cornerRadius(12)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                }
                
            }

            
            if isAdmin {
                TabView {
                    // Dashboard Tab
                    VStack {
                        DashboardTabView(isLocked: $isLocked)
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: "tray.2.fill")
                            Text("Dashboard")
                        }
                    }
                    // Check In / Out Tab
                    VStack {
                        Check_in_out(isLocked: $isLocked)
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: "clock")
                            Text("Check In / Out")
                        }
                    }
                    // More Tab
                    VStack {
                        MoreTabView(isLocked: $isLocked)
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: "list.dash")
                            Text("More")
                        }
                    }
                }
                .accentColor(Color(hex: "283B34")) // Active Tab
                .alert("Are you sure you want to sign out?", isPresented: $showingSignOutAlert) {
                    Button("Go Back", role: .cancel) { }
                    Button("Sign Out", role: .destructive) {
                        punchsyncfb.userLogout()
                    }
                }
            } else {
                TabView {
                    // Schedule View
                    VStack {
                        EmployeeScheduleView()
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: "calendar")
                            Text("Schedule")
                        }
                    }
                    // Attest View
                    VStack {
                        EmployeeAttestView()
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: "clock")
                            Text("Attest")
                        }
                    }
                    // More Tab
                    VStack {
                        EmployeeMoreTabView()
                    }
                    .tabItem {
                        VStack {
                            Image(systemName: "list.dash")
                            Text("More")
                        }
                    }
                }
                .accentColor(Color(hex: "283B34")) // Active Tab
                .alert("Are you sure you want to sign out?", isPresented: $showingSignOutAlert) {
                    Button("Go Back", role: .cancel) { }
                    Button("Sign Out", role: .destructive) {
                        punchsyncfb.userLogout()
                    }
                }
            }
        }
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
    HomeView(isAdmin: false) // Eller false för att testa olika scenarier
}
