//
//  ProfileView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/30/23.
//

import SwiftUI

enum FriendRequestStatus {
    case requestSent, requestSending, requestError
}

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var friendship: UserFriend? = nil
    @State var requestStatus: FriendRequestStatus? = nil
    private var user: UserInfo
    @State var sharedDebts: [Debt]? = nil
    @State var transactionsState: LoadingState = .loading
    //@State var friendship: Friendship? = nil
    
    /*var isFriendUser1: Bool {
        friendship?.user1 == user.id
    }*/
    
    init(user: UserInfo, friendship: UserFriend? = nil) {
        self.user = user
        self.friendship = friendship
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(uiColor: UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            VStack {
                ZStack {
                    if colorScheme != .dark {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.42, green: 0.61, blue: 0.36), Color(red: 0.36, green: 0.53, blue: 0.32)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .shadow(.inner(color: .black.opacity(0.25), radius: 0, x: 0, y: -3))
                            )
                            .roundedCorners(24, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                            .frame(maxHeight: 140)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .roundedCorners(24, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                            .frame(maxHeight: 140)
                    }
                    ZStack {
                        UserPhotoView(size: 80, imagePath: user.avatar_url)
                            .offset(y: -80)
                            .zIndex(1)
                        VStack {
                            Text(user.name ?? "User unknown")
                                .font(.system(size: 36, weight: .semibold, design: .rounded))
                            HStack {
                                if let friendship = friendship {
                                    Button {
                                        Task {
                                            //try await acceptRequest(friendship: friendship)
                                        }
                                    } label: {
                                        if friendship.status == 0 {
                                            Text("Accept")
                                                .font(.headline)
                                        } else {
                                            Text("Friends")
                                                .font(.headline)
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.primaryAction)
                                    .disabled(friendship.status == 1)
                                } else {
                                    Button {
                                        Task {
                                            /*if let currentUser = authViewModel.currentUserInfo {
                                             requestStatus = .requestSending
                                             try await handleAddFriend(user1: currentUser, user2: user)
                                             }*/
                                        }
                                    } label: {
                                        if requestStatus == .requestSending {
                                            ProgressView()
                                                .progressViewStyle(.circular)
                                                .controlSize(.small)
                                        } else {
                                            Text("Add friend")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.layoutGreen, lineWidth: 1)
                                                )
                                        }
                                    }
                                    .background(Color.primaryAction)
                                    .cornerRadius(16)
                                    .disabled(requestStatus == .requestSending)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .padding(.top, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(uiColor: UIColor.secondarySystemGroupedBackground))
                                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 4)
                                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 0)
                        )
                        .frame(maxHeight: 100)
                    }
                    .padding()
                    .offset(y: 60)
                }.zIndex(2)
                List {
                    TransactionsView(transactionsList: $sharedDebts, state: $transactionsState)
                }
                .padding(.top, 65)
                .refreshable {
                    try? await loadTransactions()
                }
            }
        }
        .task {
            self.transactionsState = .loading
            if self.sharedDebts == nil {
                try? await loadTransactions()
            }
            if self.friendship == nil {
                self.friendship = try? await SupabaseManager.shared.getFriendship(friendId: user.id)
            }
        }
    }
    
    func loadTransactions() async throws {
        do {
            self.sharedDebts = try await SupabaseManager.shared.getSharedDebtsWithExpenses(friendId: user.id)
            self.transactionsState = .success
        } catch {
            self.transactionsState = .error
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(user: UserInfo.example)
            .environmentObject(AuthenticationViewModel())
    }
}
