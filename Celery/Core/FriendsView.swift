//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

private class FriendsViewModel: ObservableObject {
    @Published var friendsList: [UserFriend]?
    @Published var loading: LoadingState = .loading
    
    @MainActor
    func fetchData() async throws {
        self.loading = .loading
        do {
            self.friendsList = try await SupabaseManager.shared.getUsersFriends()
            self.loading = .success
        } catch {
            self.loading = .error
        }
    }
}

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject fileprivate var viewModel = FriendsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if viewModel.loading == .success {
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
                    } else if viewModel.loading == .loading {
                        VStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    } else if viewModel.loading == .error {
                        VStack {
                            Text("Something went wrong!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
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
        .task {
            try? await viewModel.fetchData()
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthenticationViewModel())
}
