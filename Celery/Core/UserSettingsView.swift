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
            //AvatarUploadView()
            List {
                /*if let user = user {
                 Section {
                 Text("User id: \(user.id)")
                 Text("Display name: \(user.displayName ?? "")")
                 if let email = user.email {
                 Text("Email: \(email)")
                 }
                 /*if let photoURL = authViewModel.currentUser?.photoURL {
                  Text("Photo URL: \(photoURL.absoluteString)")
                  }*/
                 } header: {
                 Text("User information")
                 }
                 }*/
                Button("Sign out") {
                    Task {
                        try? await authViewModel.signOut()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color(uiColor: UIColor.secondaryLabel))
                    }
                }
            }
            /*.task {
             try? await self.getCurrentUser()
             }*/
        }
        .onAppear {
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.label
            ]
        }
        .onDisappear {
            UINavigationBar.appearance().titleTextAttributes = nil
        }
    }
}

#Preview {
    UserSettingsView()
        .environmentObject(AuthenticationViewModel())
}
