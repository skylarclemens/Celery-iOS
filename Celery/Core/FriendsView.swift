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
            if self.friendsList == nil {
                self.friendsList = try await SupabaseManager.shared.getUsersFriends()
            }
            self.loading = .success
        } catch {
            self.loading = .error
        }
    }
}

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var model: Model
    @StateObject fileprivate var viewModel = FriendsViewModel()
    
    var body: some View {
        NavigationStack {
            LazyVStack {
                if viewModel.loading == .success {
                    if let friendsList = viewModel.friendsList {
                        ForEach(friendsList) { friend in
                            if let user = friend.friend,
                               let debts = model.debts {
                                let sharedDebts = debts.filter {
                                    $0.creditor?.id == user.id || $0.debtor?.id == user.id
                                }
                                FriendOverviewView(debts: sharedDebts, user: user)
                            }
                        }
                    } else {
                        Text("No friends")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                    }
                } else if viewModel.loading == .loading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                } else if viewModel.loading == .error {
                    VStack {
                        Text("Something went wrong!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                }
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea()
            )
            .animation(.default, value: viewModel.friendsList)
            .navigationTitle("Friends")
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
        .environmentObject(Model())
}
