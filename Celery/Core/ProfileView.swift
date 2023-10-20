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
    
    var balances: Balance {
        balanceCalc(using: sharedDebts)
    }
    
    init(user: UserInfo, friendship: UserFriend? = nil) {
        self.user = user
        self.friendship = friendship
    }
    
    @State private var openPayView: Bool = false
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(uiColor: UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 12) {
                            UserPhotoView(size: 60, imagePath: user.avatar_url)
                            Text(user.name ?? "User unknown")
                                .font(.system(size: 36, weight: .semibold, design: .rounded))
                        }
                        HStack {
                            Group {
                                if let friendship = friendship {
                                    Button {
                                        Task {
                                            //try await acceptRequest(friendship: friendship)
                                        }
                                    } label: {
                                        Text(friendship.status == 0 ? "Accept" : "Friends")
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Color.primaryAction)
                                    .disabled(friendship.status == 1)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.layoutGreen, lineWidth: friendship.status == 0 ? 1 : 0)
                                    )
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
                                            Label("Add", systemImage: "plus")
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(Color.primaryAction)
                                    .disabled(requestStatus == .requestSending)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.layoutGreen, lineWidth: 1)
                                    )
                                }
                            }
                            Spacer()
                            Button {
                                openPayView = true
                            } label: {
                                Label("Pay", systemImage: "dollarsign")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.primaryAction)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.layoutGreen, lineWidth: 1)
                            )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.secondary.opacity(0.25), lineWidth: 0.5)
                                )
                        )
                    }
                    .padding(.horizontal)
                    UserBalanceView(balanceOwed: balances.owed, balanceOwe: balances.owe)
                        .animation(.default, value: balances)
                        .padding(.top, 12)
                        .padding(.horizontal)
                    VStack(alignment: .leading) {
                        Text("Transactions")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary.opacity(0.9))
                            .padding(.horizontal)
                            .padding(.top, 8)
                        TransactionsScrollView(transactionsList: sharedDebts ?? [], state: $transactionsState)
                    }
                    .padding(.horizontal)
                }
            }
            .refreshable {
                try? await loadTransactions()
            }
        }
        .sheet(isPresented: $openPayView) {
            if let currentUser = authViewModel.currentUserInfo {
                PayView(creditor: balances.owed > balances.owe ? currentUser : user, debtor: balances.owed < balances.owe ? currentUser : user, debts: sharedDebts, amount: abs(balances.total))
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
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
}

extension ProfileView {
    func loadTransactions() async throws {
        do {
            self.sharedDebts = try await SupabaseManager.shared.getSharedDebtsWithExpenses(friendId: user.id)
            self.transactionsState = .success
        } catch {
            self.transactionsState = .error
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
        ProfileView(user: UserInfo.example)
            .environmentObject(AuthenticationViewModel())
    }
}
