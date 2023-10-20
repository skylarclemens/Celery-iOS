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
    var usersSharedDebts: [Debt] {
        if let debts,
           let currentUser = authViewModel.currentUserInfo {
            return debts.filter {
                $0.creditor?.id == currentUser.id || $0.debtor?.id == currentUser.id
            }
        } else {
            return []
        }
    }
    var balances: Balance {
        guard !usersSharedDebts.isEmpty else { return Balance() }
        return balanceCalc(using: usersSharedDebts)
    }
    
    @State var showEditGroup: Bool = false
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            VStack {
                ScrollView() {
                    VStack(alignment: .leading) {
                        Text("Members")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .padding(.leading)
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
                    .padding(.top, 5)
                    UserBalanceView(balanceOwed: balances.owed, balanceOwe: balances.owe)
                        .animation(.default, value: balances)
                        .padding()
                    VStack(alignment: .leading) {
                        Text("Transactions")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .padding(.leading)
                        TransactionsScrollView(transactionsList: debts ?? [], state: $loading)
                            .animation(.default, value: debts)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .refreshable {
                    try? await fetchData()
                }
            }
        }
        .navigationTitle(group.group_name ?? "Group")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showEditGroup = true
                        //showDeleteAlert = true
                    } label: {
                        Label("Manage group", systemImage: "gear")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $showEditGroup) {
            EditGroupView(group: group, members: members, path: $path)
        }
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
    
    func balanceCalc(using debts: [Debt]?) -> Balance {
        var balance = Balance()
        if let transactionsList = debts,
           let currentUser = authViewModel.currentUserInfo {
            for debt in transactionsList {
                let amount = debt.amount ?? 0.00
                if debt.paid ?? true {
                    continue
                }
                if debt.creditor?.id == currentUser.id {
                    balance.total += amount
                    balance.owed += amount
                } else {
                    balance.total -= amount
                    balance.owe += amount
                }
            }
        }
        return balance
    }
}

#Preview {
    NavigationStack {
        GroupView(group: GroupInfo.example, path: .constant(NavigationPath()))
            .environmentObject(AuthenticationViewModel())
    }
}

struct EmptyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}
