//
//  EditGroupView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/18/23.
//

import SwiftUI

struct EditGroupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    let group: GroupInfo
    @State var groupName: String = ""
    @State var groupMembers: [UserInfo] = []
    @State var avatarUrl: String = ""
    
    init(group: GroupInfo, members: [UserInfo]?) {
        self.group = group
        self._groupName = State(initialValue: group.group_name ?? "")
        self._groupMembers = State(initialValue: members ?? [])
        self._avatarUrl = State(initialValue: group.avatar_url ?? "")
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
                SelectUsersView(users: $groupMembers)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        dismiss()
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
                            }
                            dismiss()
                        case .group:
                            try? await deleteGroup()
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
    
    func deleteGroup() async throws {
        do {
            try await SupabaseManager.shared.deleteGroup(groupId: group.id)
        } catch {
            print("Error deleting group")
        }
    }
    
    func removeUser(_ id: UUID) async throws {
        do {
            try await SupabaseManager.shared.removeUserFromGroup(userId: id, groupId: group.id)
        } catch {
            print("Error removing user from group")
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
    EditGroupView(group: GroupInfo.example, members: [UserInfo.example])
        .environmentObject(AuthenticationViewModel())
}
