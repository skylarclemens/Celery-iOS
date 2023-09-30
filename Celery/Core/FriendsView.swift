//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

private class FriendsViewModel: ObservableObject {
    @Published var friendsList: [UserFriend]?
    @Published var loading = false
    
    @MainActor
    func fetchData() async throws {
        loading = true
        self.friendsList = try? await SupabaseManager.shared.getUsersFriends()
        loading = false
    }
}

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject fileprivate var viewModel = FriendsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if let friendsList = viewModel.friendsList {
                        ForEach(friendsList) { friend in
                            NavigationLink {
                                if let currentFriend = friend.friend {
                                    ProfileView(user: currentFriend)
                                }
                            } label: {
                                HStack {
                                    UserPhotoView(size: 40, imagePath: friend.friend?.avatar_url)
                                    Text(friend.friend?.name ?? "Unknown user")
                                }
                            }
                            .listRowInsets(EdgeInsets(.init(top: 8, leading: 8, bottom: 8, trailing: 12)))
                        }
                    } else {
                        Text("No friends")
                            .foregroundStyle(.secondary)
                    }
                }
                .animation(.default, value: viewModel.friendsList)
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
            .statusBarColorScheme(.dark, showBackground: true, backgroundColor: Color.primaryAction)
            .toolbar {
                NavigationLink {
                    QueryUsersView()
                        .navigationTitle("Search")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
            }
        }
        .tint(.white)
        .task {
            try? await viewModel.fetchData()
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthenticationViewModel())
}
