//
//  EditGroupView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/18/23.
//

import SwiftUI

struct EditGroupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var model: Model
    @Environment(\.dismiss) var dismiss
    
    let group: GroupInfo
    @State var groupName: String = ""
    @State var groupMembers: [UserInfo] = []
    @State var membersToAdd: [UserInfo] = []
    @State var avatarUrl: String = ""
    
    @Binding var path: NavigationPath
    
    init(group: GroupInfo, members: [UserInfo]?, path: Binding<NavigationPath>) {
        self.group = group
        self._groupName = State(initialValue: group.group_name ?? "")
        self._groupMembers = State(initialValue: members ?? [])
        self._avatarUrl = State(initialValue: group.avatar_url ?? "")
        self._path = path
    }
    
    @State var loading: LoadingState = .success
    
    @State var openUserSelection: Bool = false
    
    @State var showAlert: Bool = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var alertAction: AlertAction = .group
    var actionButtonText: String {
        switch alertAction {
        case .user:
            return "Remove"
        case .leave:
            return "Leave"
        case .group:
            return "Delete"
        }
    }
    
    enum AlertAction {
        case user(id: UUID)
        case leave
        case group
    }
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
                                let isCurrentUser = authViewModel.isCurrentUser(userId: user.id)
                                HStack(spacing: 12) {
                                    UserPhotoView(size: 40, imagePath: user.avatar_url)
                                    Text(isCurrentUser ? "You" : user.name ?? "Unknown name")
                                        .font(.system(size: 16))
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                }
                                .swipeActions(edge: .trailing) {
                                    if !isCurrentUser {
                                        Button(role: .destructive) {
                                            self.alertTitle = "Remove \(user.name ?? "user")"
                                            self.alertMessage = "Are you sure you want to remove this user from the group?"
                                            self.alertAction = .user(id: user.id)
                                            showAlert = true
                                        } label: {
                                            Label("Delete group", systemImage: "trash")
                                                .foregroundStyle(.red)
                                        }
                                    }
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
                                Image(systemName: "plus")
                            }
                            .foregroundStyle(Color.secondary)
                            .padding(.vertical, 4)
                            .tint(Color(uiColor: UIColor.systemGroupedBackground))
                        }
                    }
                    Section {
                        Button {
                            self.alertTitle = "Leaving \(group.group_name ?? "group")"
                            self.alertMessage = "Are you sure you want to leave this group?"
                            self.alertAction = .leave
                            showAlert = true
                        } label: {
                            Label("Leave group", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                    Section {
                        Button(role: .destructive) {
                            self.alertTitle = "Delete \(group.group_name ?? "group")"
                            self.alertMessage = "Are you sure you want to permanently delete this group?\n\nAll group data will be deleted. You cannot undo this action."
                            self.alertAction = .group
                            showAlert = true
                        } label: {
                            Label("Delete group", systemImage: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $openUserSelection) {
                SelectUsersView(users: $membersToAdd, existingGroupMembers: groupMembers, selectToAdd: true)
            }
            .onChange(of: membersToAdd) { newValue in
                Task {
                    if !newValue.isEmpty {
                        var newUsers: [UserGroupModel] = []
                        for user in newValue {
                            newUsers.append(UserGroupModel(user_id: user.id, group_id: group.id))
                        }
                        do {
                            let addedUsers: [UserInfo]? = try await SupabaseManager.shared.addUsersToGroup(groupUsers: newUsers)
                            if let addedUsers {
                                self.groupMembers += addedUsers
                            }
                            self.membersToAdd = []
                        } catch {
                            print("Error adding new users")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        if self.groupName != group.group_name {
                            Task {
                                await updateGroup()
                                dismiss()
                            }
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .alert(self.alertTitle, isPresented: $showAlert) {
                Button(actionButtonText, role: .destructive) {
                    Task {
                        switch alertAction {
                        case let .user(userId):
                            try? await removeUser(userId)
                            groupMembers.removeAll(where: { $0.id == userId })
                        case .leave:
                            if let currentUser = authViewModel.currentUserInfo {
                                try? await removeUser(currentUser.id)
                                model.removeGroup(group.id)
                            }
                            path.removeLast(path.count)
                            dismiss()
                        case .group:
                            await deleteGroup()
                            path.removeLast(path.count)
                            dismiss()
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(self.alertMessage)
            }
            .navigationTitle("Manage group")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func deleteGroup() async {
        try? await model.deleteGroup(group.id)
    }
    
    func removeUser(_ id: UUID) async throws {
        do {
            try await SupabaseManager.shared.removeUserFromGroup(userId: id, groupId: group.id)
        } catch {
            print("Error removing user from group")
        }
    }
    
    func updateGroup() async {
        let updatedGroup = GroupInfo(id: group.id, group_name: groupName, created_at: group.created_at, avatar_url: avatarUrl, color: group.color)
        try? await model.updateGroup(updatedGroup)
    }
}

#Preview {
    EditGroupView(group: GroupInfo.example, members: [UserInfo.example], path: .constant(NavigationPath()))
        .environmentObject(AuthenticationViewModel())
        .environmentObject(Model())
}
