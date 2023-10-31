//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

private class FriendsLists: ObservableObject {
    @Published var friendsList: [UserFriend]?
    @Published var requestsList: [UserFriend]?
}

struct FriendsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var model: Model
    @StateObject fileprivate var friends = FriendsLists()
    
    @State private var loading: LoadingState = .loading
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    if loading == .success {
                        if let requestsList = friends.requestsList,
                           !requestsList.isEmpty {
                            NavigationLink {
                                FriendRequestsList()
                                    .environmentObject(friends)
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
                        if let friendsList = friends.friendsList {
                            if !friendsList.isEmpty {
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
                        }
                    } else if loading == .loading {
                        VStack {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    } else if loading == .error {
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
                .animation(.default, value: friends.friendsList)
            }
            .background(
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea()
            )
            .refreshable {
                try? await fetchFriends()
                try? await fetchRequests()
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
            loading = .loading
            try? await fetchData()
        }
    }
}

extension FriendsView {
    func fetchData() async throws {
        do {
            if self.friends.friendsList == nil {
                try await fetchFriends()
            }
            if self.friends.requestsList == nil {
                try await fetchRequests()
            }
            self.loading = .success
        } catch {
            self.loading = .error
        }
    }
    
    func fetchFriends() async throws {
        self.friends.friendsList = try? await SupabaseManager.shared.getUsersFriends()
    }
    
    func fetchRequests() async throws {
        self.friends.requestsList = try? await SupabaseManager.shared.getAllFriendRequests()
    }
}

#Preview {
    FriendsView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(Model())
}

struct FriendRequestsList: View {
    @EnvironmentObject fileprivate var friends: FriendsLists
    
    var body: some View {
        List {
            if let list = friends.requestsList {
                ForEach(Array(list.enumerated()), id: \.element) { index, element in
                    RequestRow(index: index, user: element.user, request: element)
                }
            }
        }
        .listStyle(.inset)
        .animation(.default, value: friends.requestsList)
        .navigationTitle("Requests")
    }
}

struct RequestRow: View {
    let index: Int
    let user: UserInfo?
    let request: UserFriend
    @State var friendship: UserFriend? = nil
    @State var requestStatus: FriendRequestStatus? = nil
    
    @EnvironmentObject fileprivate var friends: FriendsLists
    
    var body: some View {
        HStack {
            HStack {
                UserPhotoView(size: 45, imagePath: user?.avatar_url)
                Text(user?.name ?? "Unknown name")
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .truncationMode(.tail)
            }
            Spacer()
            HStack(spacing: 12) {
                if self.friendship != nil {
                    AnimatedCheckmark(color: .secondary)
                        .scaleEffect(0.8)
                        .padding(.trailing, 8)
                } else if requestStatus == .requestSending {
                    ProgressView()
                } else {
                    Button {
                        Task {
                            try? await ignoreFriendRequest(request: self.request, index: index)
                        }
                    } label: {
                        Text("Ignore")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    Button("Accept") {
                        Task {
                            try? await acceptFriendRequest(request: self.request, index: index)
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
        .transition(.opacity)
    }
}

extension RequestRow {
    func acceptFriendRequest(request: UserFriend, index: Int) async throws {
        self.requestStatus = .requestSending
        do {
            try await SupabaseManager.shared.updateFriendStatus(user1: request.user!.id, user2: request.friend!.id, status: 1)
            self.friendship = try await SupabaseManager.shared.addNewFriend(request: request)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
                self.friends.requestsList?.remove(at: index)
            }
            if let friendship = self.friendship {
                self.friends.friendsList?.append(friendship)
            }
            self.requestStatus = .requestSent
        } catch {
            self.requestStatus = .requestError
        }
    }
    
    func ignoreFriendRequest(request: UserFriend, index: Int) async throws {
        self.requestStatus = .requestSending
        do {
            try await SupabaseManager.shared.updateFriendStatus(user1: request.user!.id, user2: request.friend!.id, status: 2)
            self.friends.requestsList?.remove(at: index)
            self.requestStatus = .requestSent
        } catch {
            self.requestStatus = .requestError
        }
    }
}

#Preview {
    NavigationStack {
        FriendRequestsList()
            .environmentObject(FriendsLists())
    }
}
