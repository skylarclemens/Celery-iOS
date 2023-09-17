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
    @State var requestStatus: FriendRequestStatus? = nil
    @State var friendship: Friendship? = nil
    private var user: UserInfo
    var isFriendUser1: Bool {
        friendship?.user1 == user.id
    }
    
    init(user: UserInfo) {
        self.user = user
        
        /*let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .shadow: NSShadow()
        ]
        
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UINavigationBar.appearance().titleTextAttributes = attrs*/
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let proxy = UINavigationBar.appearance()
        proxy.tintColor = .white
        proxy.standardAppearance = appearance
        proxy.scrollEdgeAppearance = appearance
        
        /*let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UINavigationBar.appearance().tintColor = .white*/
    }
    
    var body: some View {
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
                    UserPhotoView(size: 80, photoURL: user.photoURL ?? nil)
                        .offset(y: -80)
                        .zIndex(1)
                    VStack {
                        Text(user.displayName ?? "User unknown")
                            .font(.system(size: 36, weight: .semibold, design: .rounded))
                        HStack {
                            if let friendship = friendship {
                                Button {
                                    Task {
                                        try await acceptRequest(friendship: friendship)
                                    }
                                } label: {
                                    if friendship.status == 0 && !isFriendUser1 {
                                        Text("Pending")
                                            .font(.headline)
                                    } else if friendship.status == 0 && isFriendUser1 {
                                        Text("Accept")
                                            .font(.headline)
                                    } else {
                                        Text("Friends")
                                            .font(.headline)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.primaryAction)
                                .disabled((friendship.status == 0 && !isFriendUser1) || friendship.status == 1)
                            } else {
                                Button {
                                    Task {
                                        if let currentUser = authViewModel.currentUserInfo {
                                            requestStatus = .requestSending
                                            try await handleAddFriend(user1: currentUser, user2: user)
                                        }
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
            
            ScrollView {
                VStack {
                    Text("")
                }
                .padding(.top, 80)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            Task {
                guard let currentUser = authViewModel.currentUserInfo else { return }
                friendship = try await FriendManager.shared.getFriendship(userIds: [currentUser.id, user.id])
            }
        }
    }
    
    func handleAddFriend(user1: UserInfo, user2: UserInfo) async throws {
        let newFriendship = Friendship(user1: user1.id, user2: user2.id, status: 0)
        do {
            try await FriendManager.shared.createNewFriendship(friendship: newFriendship)
            self.friendship = newFriendship
            requestStatus = .requestSent
        } catch {
            print(error)
            requestStatus = .requestError
        }
    }
    
    func acceptRequest(friendship: Friendship) async throws {
        let newFriendship = Friendship(user1: friendship.user1, user2: friendship.user2, status: 1)
        do {
            try await FriendManager.shared.updateFriendship(friendship: newFriendship)
            self.friendship = newFriendship
        } catch {
            print(error)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(user: UserInfo.example)
            .environmentObject(AuthenticationViewModel())
    }
}
