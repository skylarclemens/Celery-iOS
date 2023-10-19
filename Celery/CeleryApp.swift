//
//  CeleryApp.swift
//  Celery
//
//  Created by Skylar Clemens on 7/12/23.
//

import SwiftUI

@main
struct CeleryApp: App {
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
