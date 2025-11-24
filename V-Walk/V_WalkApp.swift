//
//  V_WalkApp.swift
//  V-Walk
//
//  Created by 강효민 on 11/23/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct V_WalkApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userManager = UserManager()
    @StateObject var playerManager = PlayerManager()
    var body: some Scene {
      WindowGroup {
          if userManager.isLoggedIn {
              ContentView()
                    .environmentObject(userManager)
                    .environmentObject(playerManager)
          }
          else {
              LoginView()
                  .environmentObject(userManager)
          }
         
        }
      }
    }

