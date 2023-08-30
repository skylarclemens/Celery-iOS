//
//  UserSettingsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/28/23.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var user: UserInfo? = nil
    
    func getCurrentUser() async throws {
        let authUser = try authViewModel.getUser()
        if let currentUser = authUser {
            self.user = try await UserManager.shared.getUser(userId: currentUser.uid)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if let user = user {
                    Section {
                        Text("User id: \(user.id)")
                        Text("Display name: \(user.displayName ?? "")")
                        if let email = user.email {
                            Text("Email: \(email)")
                        }
                    } header: {
                        Text("User information")
                    }
                }
                
                Button("Sign out") {
                    try? authViewModel.signOut()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .task {
                try? await self.getCurrentUser()
            }
        }
    }
}

#Preview {
    UserProfileView()
        .environmentObject(AuthenticationViewModel())
}
