//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI



struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var friendsList: [UserFriend]?
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if let friendsList {
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
        .onAppear {
            Task {
                self.friendsList = try await SupabaseManager.shared.getUsersFriends()
            }
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthenticationViewModel())
}
