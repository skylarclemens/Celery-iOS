//
//  GroupView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import SwiftUI

struct GroupView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var group: GroupInfo
    
    @State var members: [UserInfo]?
    @State var debts: [Debt]?
    @State var loading: LoadingState = .loading
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            VStack {
                ScrollView() {
                    VStack(alignment: .leading) {
                        Text("Members")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary.opacity(0.9))
                            .textCase(nil)
                            .padding(.leading)
                            .padding(.top, 5)
                        ScrollView(.horizontal, showsIndicators: false) {
                            if let members = members {
                                HStack(spacing: 24) {
                                    ForEach(members) { user in
                                        NavigationLink {
                                            ProfileView(user: user)
                                        } label: {
                                            VStack {
                                                UserPhotoView(size: 45, imagePath: user.avatar_url)
                                                Text(authViewModel.isCurrentUser(userId: user.id) ? "You" : user.name ?? "Unknown name")
                                                    .font(.system(size: 12))
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.center)
                                                    .truncationMode(.tail)
                                            }
                                        }
                                        .frame(maxWidth: 60)
                                        .disabled(authViewModel.isCurrentUser(userId: user.id))
                                        .buttonStyle(EmptyButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .frame(height: 65)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        )
                    }
                    .padding(.horizontal)
                    TransactionsScrollView(transactionsList: $debts, state: $loading)
                        .animation(.default, value: debts)
                }
            }
        }
        .navigationTitle(group.group_name ?? "Group")
        .navigationBarTitleDisplayMode(.large)
        .task {
            try? await fetchData()
        }
    }
    
    func fetchData() async throws {
        self.loading = .loading
        do {
            if self.members == nil {
                self.members = try await SupabaseManager.shared.getGroupMembers(groupId: group.id)
            }
            if self.debts == nil {
                self.debts = try await SupabaseManager.shared.getGroupDebtsWithExpenses(groupId: group.id)
            }
            self.loading = .success
        } catch {
            self.loading = .error
        }
    }
}

#Preview {
    NavigationStack {
        GroupView(group: GroupInfo.example)
            .environmentObject(AuthenticationViewModel())
    }
}

struct EmptyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}
