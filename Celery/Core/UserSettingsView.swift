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
    
    var currentUser: UserInfo?
    
    var body: some View {
        NavigationStack {
            //AvatarUploadView()
            List {
                if let user = currentUser {
                    Button {
                        
                    } label: {
                        HStack(spacing: 14) {
                            UserPhotoView(size: 45, imagePath: user.avatar_url)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name ?? "")
                                if let username = user.username {
                                    Text("@\(username)")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .tint(.primary)
                }
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
                            .foregroundStyle(Color(uiColor: UIColor.secondaryLabel), Color(uiColor: UIColor.tertiarySystemFill))
                    }
                }
            }
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
    UserSettingsView(currentUser: UserInfo.example)
        .environmentObject(AuthenticationViewModel())
}
