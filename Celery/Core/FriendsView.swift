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
    let friend: UserModel?
    let status: Int?
    let status_change: Date?
}

/*
 const { data, error } = await supabase
           .from('user_friend')
           .select('friend_id(*)')
           .eq('user_id', userId)
           .eq('status', 1)
 */

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
                //try await supabaseAuthViewModel.getCurrentSession()
                try await getUsersFriends()
            }
        }
    }
    
    func getUsersFriends() async throws {
        do {
            let currentUserId = try await SupabaseManager.shared.client.auth.session.user.id
            print(currentUserId)
            self.friendsList = try await SupabaseManager.shared.client.database.from("user_friend")
                .select(columns: """
                *,
                friend: friend_id(*)
                """)
                .eq(column: "user_id", value: currentUserId)
                .eq(column: "status", value: 1)
                .execute()
                .value
            print(friendsList)
            /*let response = try await SupabaseManager.shared.client.database.from("user_friend")
                .select(columns: "friend_id!inner(*)")
                .eq(column: "user_id", value: currentUserId)
                .eq(column: "status", value: 1)
                .execute()
            print(response.status)
            print(response.underlyingResponse.response)
            print(response.underlyingResponse.data)
            print(String(data: response.underlyingResponse.data, encoding: .utf8))*/
        } catch {
            print("Error fetching friends: \(error)")
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthenticationViewModel())
}
