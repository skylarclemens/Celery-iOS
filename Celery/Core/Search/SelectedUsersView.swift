//
//  SelectedUsersView.swift
//  Celery
//
//  Created by Skylar Clemens on 11/1/23.
//

import SwiftUI

struct SelectedUsersView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var model: Model
    
    @Binding var selectedUsers: [UserInfo]
    @Binding var selectedGroup: GroupInfo?
    @Binding var selectedGroupMembers: [UserInfo]?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Selected")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.9))
                    .padding(.leading)
                if let selectedGroup {
                    HStack {
                        Text(selectedGroup.group_name ?? "Unknown group name")
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Button {
                            self.selectedGroup = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Color(uiColor: UIColor.secondaryLabel), Color(uiColor: UIColor.tertiarySystemFill))
                        }
                    }
                    .font(.system(size: 14))
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 8))
                    .background(Color(UIColor.systemGroupedBackground))
                    .clipShape(Capsule())
                }
                Spacer()
                Button("Clear") {
                    self.selectedGroup = nil
                    self.selectedGroupMembers = nil
                    self.selectedUsers = self.selectedUsers.filter {
                        authViewModel.isCurrentUser(userId: $0.id)
                    }
                }
                .font(.system(size: 14))
                .padding(.trailing)
                .disabled(selectedUsers.isEmpty)
            }
            .frame(height: 34)
            if !selectedUsers.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(selectedUsers) { user in
                            let userSelected = selectedUsers.firstIndex(where: { $0.id == user.id })
                            VStack {
                                ZStack(alignment: .topTrailing) {
                                    if !authViewModel.isCurrentUser(userId: user.id) {
                                        Button {
                                            if let userSelected {
                                                selectedUsers.remove(at: userSelected)
                                            }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 16))
                                                .foregroundStyle(Color(UIColor.label).opacity(0.5), Color(UIColor.systemGroupedBackground))
                                        }
                                        .zIndex(1)
                                        .offset(x: 8)
                                    }
                                    UserPhotoView(size: 45, imagePath: user.avatar_url)
                                }
                                Text(authViewModel.isCurrentUser(userId: user.id) ? "You" : user.name ?? "Unknown name")
                                    .font(.system(size: 12))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .truncationMode(.tail)
                            }
                            .frame(maxWidth: 60)
                        }
                    }
                    .padding(.leading)
                    .padding(.bottom, 8)
                }
            }
            Divider()
        }
        .padding(.top, 8)
    }
}

#Preview {
    SelectedUsersView(selectedUsers: .constant([]), selectedGroup: .constant(GroupInfo.example), selectedGroupMembers: .constant([]))
}
