//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

private class FriendsViewModel: ObservableObject {
    @Published var friendsList: [UserFriend]?
    @Published var requestsList: [UserFriend]?
    @Published var loading: LoadingState = .loading
    
    @MainActor
    func fetchData() async throws {
        do {
            if self.friendsList == nil {
                self.friendsList = try await SupabaseManager.shared.getUsersFriends()
            }
            self.requestsList = try await SupabaseManager.shared.getAllFriendRequests()
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
            ScrollView {
                LazyVStack {
                    if viewModel.loading == .success {
                        if let requestsList = viewModel.requestsList,
                           !requestsList.isEmpty {
                            NavigationLink {
                                FriendRequestsList(list: $viewModel.requestsList, friendsList: $viewModel.friendsList)
                            } label: {
                                HStack {
                                    Text("Requests")
                                        .font(.system(size: 16))
                                    Text(requestsList.count, format: .number)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(6)
                                        .background(
                                            Circle()
                                                .fill(.red)
                                        )
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.tertiary)
                                        .padding(.leading, 4)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.regularMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.tertiary.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
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
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
                .animation(.default, value: viewModel.friendsList)
            }
            .background(
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea()
            )
            .refreshable {
                try? await viewModel.fetchData()
            }
            .navigationTitle("Friends")
            .navigationBarTitleDisplayMode(.inline)
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
            viewModel.loading = .loading
            try? await viewModel.fetchData()
        }
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(Model())
}

struct FriendRequestsList: View {
    @Binding var list: [UserFriend]?
    @Binding var friendsList: [UserFriend]?
    
    var body: some View {
        List {
            ForEach(list ?? []) { request in
                if let user = request.user {
                    RequestRow(user: user, request: request, friendsList: $friendsList)
                }
            }
        }
        .listStyle(.inset)
        .navigationTitle("Requests")
    }
}

struct RequestRow: View {
    let user: UserInfo
    let request: UserFriend
    @State var friendship: UserFriend? = nil
    @State var requestStatus: FriendRequestStatus? = nil
    @Binding var friendsList: [UserFriend]?
    
    var body: some View {
        HStack {
            HStack {
                UserPhotoView(size: 45, imagePath: user.avatar_url)
                Text(user.name ?? "Unknown name")
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .truncationMode(.tail)
            }
            Spacer()
            HStack(spacing: 12) {
                if self.friendship != nil {
                    Text("Accepted")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary)
                } else if requestStatus == .requestSending {
                    ProgressView()
                } else {
                    /*Button {
                        
                    } label: {
                        Text("Ignore")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }*/
                    Button("Accept") {
                        Task {
                            try? await acceptFriendRequest(request: self.request)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(Color.primaryAction)
                }
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 10)
        .listRowInsets(EdgeInsets())
    }
}

extension RequestRow {
    func acceptFriendRequest(request: UserFriend) async throws {
        self.requestStatus = .requestSending
        do {
            try await SupabaseManager.shared.updateFriendStatus(user1: request.user!.id, user2: request.friend!.id, status: 1)
            self.friendship = try await SupabaseManager.shared.addNewFriend(request: request)
            self.requestStatus = .requestSent
        } catch {
            self.requestStatus = .requestError
        }
    }
}

#Preview {
    NavigationStack {
        FriendRequestsList(list: .constant([UserFriend.example]), friendsList: .constant([]))
    }
}
