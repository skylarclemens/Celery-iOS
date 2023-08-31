//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var friendsList: [Friendship]?
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if let friendsList {
                        ForEach(friendsList, id: \.self) { friendship in
                            Text(friendship.userIdsString)
                        }
                    } else {
                        Text("No friends")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Friends")
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
                    friendsList = try await FriendManager.shared.getUsersFriendships(userId: currentUser.id)
                }
            }
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthenticationViewModel())
}
