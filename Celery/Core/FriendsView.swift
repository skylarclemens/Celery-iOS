//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var friendsList: [UserInfo]?
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if let friendsList {
                        ForEach(friendsList) { friend in
                            NavigationLink {
                                ProfileView(user: friend)
                            } label: {
                                Text(friend.displayName ?? "Unknown user")
                            }
                        }
                    } else {
                        Text("No friends")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
            .statusBarColorScheme(.dark, showBackground: true, backgroundColor: Color.primaryAction)
            .toolbar {
                NavigationLink {
                    QueryUsersView()
                        .navigationTitle("Find people")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
            }
        }
        .onAppear {
            Task {
                if let currentUser = authViewModel.currentUserInfo {
                    let friendsList = try await FriendManager.shared.getUsersFriendships(userId: currentUser.id)
                    if let friendsList {
                        let friendIds = FriendManager.shared.getFriendsIds(currentUser: currentUser, friends: friendsList)
                        self.friendsList = try await UserManager.shared.getFriendsUserInfo(friendIds: friendIds, limit: 10)
                    }
                }
            }
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthenticationViewModel())
}
