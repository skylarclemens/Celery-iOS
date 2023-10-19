//
//  CreateGroupView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import SwiftUI

struct CreateGroupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var groupName: String = ""
    @State var groupMembers: [UserInfo] = []
    @State var avatarUrl: String = ""

    @State var loading: LoadingState = .success
    
    @State var openUserSelection: Bool = false
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    Section {
                        EmptyView()
                    } header: {
                        AvatarUploadView(avatarUrl: $avatarUrl, type: .group)
                            .frame(maxWidth: .infinity)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    Section("Name") {
                        TextField("Group name", text: $groupName)
                    }
                    Section {
                        if !groupMembers.isEmpty {
                            ForEach(groupMembers) { user in
                                HStack(spacing: 12) {
                                    UserPhotoView(size: 40, imagePath: user.avatar_url)
                                    Text(authViewModel.isCurrentUser(userId: user.id) ? "You" : user.name ?? "Unknown name")
                                        .font(.system(size: 16))
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                }
                            }
                        } else {
                            Text("Add people to the group")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        HStack {
                            Text("Members")
                            Spacer()
                            Button {
                                openUserSelection = true
                            } label: {
                                if groupMembers.count <= 1 {
                                    Image(systemName: "plus")
                                } else {
                                    Text("Edit")
                                        .font(.system(size: 12))
                                }
                            }
                            .foregroundStyle(Color.secondary)
                            .padding(.vertical, 4)
                            .tint(Color(uiColor: UIColor.systemGroupedBackground))
                        }
                    }
                }
                VStack {
                    Spacer()
                    Button {
                        Task {
                            try? await createGroup()
                            dismiss()
                        }
                    } label: {
                        Group {
                            if loading != .loading {
                                Text("Create")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            } else {
                                ProgressView()
                                    .controlSize(.regular)
                                    .tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primaryAction)
                    )
                    .padding(.horizontal)
                    .disabled(loading == .loading)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .sheet(isPresented: $openUserSelection) {
                SelectUsersView(users: $groupMembers)
            }
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
            .navigationTitle("Create group")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if groupMembers.isEmpty,
               let currentUserInfo = authViewModel.currentUserInfo {
                groupMembers.append(currentUserInfo)
            }
        }
    }
    
    func createGroup() async throws {
        self.loading = .loading
        do {
            let newGroupId = UUID()
            let newGroup = GroupInfo(id: newGroupId, group_name: self.groupName, created_at: Date(), avatar_url: self.avatarUrl.isEmpty ? nil : self.avatarUrl, color: nil)
            try await SupabaseManager.shared.addNewGroup(group: newGroup)
            for member in groupMembers {
                try await SupabaseManager.shared.addNewUserGroup(userId: member.id, groupId: newGroupId)
            }
            self.loading = .success
        } catch {
            print("Error creating new group")
            self.loading = .error
        }
    }
}

#Preview {
    CreateGroupView()
        .environmentObject(AuthenticationViewModel())
}
