//
//  UserSettingsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/28/23.
//

import SwiftUI

struct UserSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Button("Sign out") {
                    try? authViewModel.signOut()
                    dismiss()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    UserSettingsView()
        .environmentObject(AuthenticationViewModel())
}
