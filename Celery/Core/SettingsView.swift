//
//  UserSettingsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/28/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var model: Model
    
    var currentUser: UserInfo?
    
    var body: some View {
        NavigationStack {
            List {
                if let user = currentUser {
                    NavigationLink {
                        UserSettingsView(user: user)
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
                }
                Button("Sign out") {
                    Task {
                        try? await authViewModel.signOut()
                        model.reset()
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
                            .font(.system(size: 24))
                            .foregroundStyle(Color(uiColor: UIColor.secondaryLabel), Color(uiColor: UIColor.tertiarySystemFill))
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(currentUser: UserInfo.example)
        .environmentObject(AuthenticationViewModel())
        .environmentObject(Model())
}

struct UserSettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    let user: UserInfo
    
    @State var name: String
    @State var username: String
    @State var avatarUrl: String
    @State var email: String
    
    @State var loadingState: LoadingState = .success
    @State var emailChange: Bool = false
    
    @State private var isEmailValid: Bool = true
    
    init(user: UserInfo) {
        self.user = user
        self._name = State(initialValue: user.name ?? "")
        self._username = State(initialValue: user.username ?? "")
        self._avatarUrl = State(initialValue: user.avatar_url ?? "")
        self._email = State(initialValue: user.email ?? "")
    }
    
    var body: some View {
        VStack {
            AvatarUploadView(avatarUrl: $avatarUrl, size: 80)
            Form {
                Section("Display name") {
                    TextField("Name", text: $name)
                }
                Section("Username") {
                    HStack(spacing: 2) {
                        Text("@")
                        TextField("username", text: $username)
                    }
                }
                Section {
                    TextField("Email", text: $email, onEditingChanged: { isChanged in
                        if !isChanged {
                            self.isEmailValid = validEmail(self.email)
                            print(self.isEmailValid)
                        }
                    })
                        .keyboardType(.emailAddress)
                        .frame(maxHeight: .infinity)
                        .padding(.leading, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.red, lineWidth: isEmailValid ? 0 : 2)
                        )
                } header: {
                    Text("Email")
                        .padding(.leading, 16)
                } footer: {
                    if !isEmailValid {
                        Text("Please enter a valid email address")
                            .padding(.leading, 16)
                            .foregroundStyle(.red)
                    }
                }
                .listRowInsets(EdgeInsets())
            }
        }
        .background(
            Rectangle()
                .fill(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        if validate() {
                            self.loadingState = .loading
                            try? await updateAccount()
                            self.loadingState = .success
                            dismiss()
                        }
                    }
                } label: {
                    if self.loadingState == .loading {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
            }
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func validEmail(_ email: String) -> Bool {
        let format = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", format)
        return emailPredicate.evaluate(with: email)
    }
    
    func validate() -> Bool {
        var isValid = true
        let emailValidate = validEmail(email)
        self.isEmailValid = emailValidate
        isValid = emailValidate
        return isValid
    }
    
    func updateAccount() async throws {
        if email != user.email {
            emailChange = true
            print(emailChange)
        } else {
            emailChange = false
            print(emailChange)
        }
        let newInfo = UserInfo(id: user.id, email: email, name: name, avatar_url: avatarUrl.isEmpty ? nil : avatarUrl, updated_at: Date(), username: username)
        try? await authViewModel.updateCurrentUserInfo(newInfo, emailChange: emailChange)
    }
}

#Preview {
    NavigationStack {
        UserSettingsView(user: UserInfo.example)
    }
}
