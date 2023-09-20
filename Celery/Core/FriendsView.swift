//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

struct UserFriendModel: Codable, Identifiable {
    let id = UUID()
    let user_id: UUID?
    let friend: UserInfo?
    let status: Int?
    let status_change: Date?
}

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var friendsList: [UserFriendModel]?
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if let friendsList {
                        ForEach(friendsList) { friend in
                            NavigationLink {
                                //ProfileView(user: friend)
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
                        .navigationTitle("Find people")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
            }
        }
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
