//
//  CeleryApp.swift
//  Celery
//
//  Created by Skylar Clemens on 7/12/23.
//

import SwiftUI
import OneSignalFramework

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       // OneSignal initialization
       let appId = Bundle.main.object(forInfoDictionaryKey: "ONESIGNAL_APP_ID") as? String ?? ""
       OneSignal.initialize(appId, withLaunchOptions: launchOptions)

       // requestPermission will show the native iOS notification permission prompt.
       OneSignal.Notifications.requestPermission({ accepted in
         print("User accepted notifications: \(accepted)")
       }, fallbackToSettings: true)
            
       return true
    }
}

@main
struct CeleryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var authViewModel = AuthenticationViewModel()
    @StateObject var model = Model()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .task {
                    try? await self.authViewModel.initializeSessionListener()
                }
                .environmentObject(model)
        }
    }
}
