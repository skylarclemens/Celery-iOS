//
//  HomeView.swift
//  Celery
//
//  Created by Skylar Clemens on 7/21/23.
//

import SwiftUI

enum LoadingState {
    case loading, success, error
}

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var model: Model
    @State var transactionsList: [Debt]?
    var filteredTransactionList: [Debt] {
        switch transactionType {
        case .all:
            return model.debts ?? []
        case .owed:
            return model.debts?.filter {
                $0.creditor?.id == authViewModel.currentUserInfo?.id
            } ?? []
        case .owe:
            return model.debts?.filter {
                $0.creditor?.id != authViewModel.currentUserInfo?.id
            } ?? []
        }
    }
    
    @State var totalBalance = 0.00
    @State var balanceOwed = 0.00
    @State var balanceOwe = 0.00
    
    @State var uniqueUsers: [UserInfo]?
    
    @State var transactionType: TransactionType = .all
    
    @State var openSettings: Bool = false
    @State var transactionsState: LoadingState = .loading
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HomeBalanceView(totalBalance: $totalBalance, balanceOwed: $balanceOwed, balanceOwe: $balanceOwe, transactionType: $transactionType)
                    .padding(.horizontal)
                /*if let uniqueUsers = uniqueUsers {
                    RecentUsersView(users: uniqueUsers)
                        .padding(.horizontal)
                }*/
                TransactionsScrollView(transactionsList: filteredTransactionList, state: $transactionsState)
            }
            .animation(.default, value: filteredTransactionList)
            .refreshable {
                await fetchDebts()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .coordinateSpace(name: "scroll")
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        openSettings = true
                    } label: {
                        UserPhotoView(size: 28, imagePath: authViewModel.currentUserInfo?.avatar_url)
                    }
                    .accessibilityLabel("Open user settings")
                }
            }
            .sheet(isPresented: $openSettings) {
                UserSettingsView(currentUser: authViewModel.currentUserInfo)
                    .tint(.blue)
            }
        }
        .onReceive(model.$debts) { newValue in
            withAnimation {
                balanceCalc(debts: newValue)
            }
        }
        .task {
            if model.debts == nil {
                transactionsState = .loading
                await fetchDebts()
            } else {
                transactionsState = .success
            }
            if model.groups == nil {
                await fetchGroups()
            }
        }
    }
}

extension HomeView {
    func organizeDebt(debt: [Debt]) {
        if !debt.isEmpty {
            let creditors = debt.map {
                $0.creditor!
            }
            let debtors = debt.map {
                $0.debtor!
            }
            let allUsers = creditors + debtors
            let uniqueUsers = Set(allUsers)
            self.uniqueUsers = Array(uniqueUsers).filter {
                $0.id != authViewModel.currentUserInfo?.id
            }
        }
    }
    
    func fetchDebts() async {
        do {
            try await model.fetchDebts()
            transactionsState = .success
        } catch {
            transactionsState = .error
        }
    }
    
    func fetchGroups() async {
        do {
            try await model.fetchGroups()
        } catch {
            print("Error fetching groups \(error)")
        }
    }
    
    func balanceCalc(debts: [Debt]?) {
        var totalBalance = 0.00
        var balanceOwed = 0.00
        var balanceOwe = 0.00
        if let transactionsList = debts,
           let currentUser = authViewModel.currentUserInfo {
            for debt in transactionsList {
                let amount = debt.amount ?? 0.00
                if debt.paid ?? true {
                    continue
                }
                if debt.creditor?.id == currentUser.id {
                    totalBalance += amount
                    balanceOwed += amount
                } else {
                    totalBalance -= amount
                    balanceOwe += amount
                }
            }
            self.totalBalance = totalBalance
            self.balanceOwed = balanceOwed
            self.balanceOwe = balanceOwe
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(Model())
    }
}

enum TransactionType: String, CaseIterable, Identifiable {
    case all, owed, owe
    
    var id: Self {
        return self
    }
}

struct RecentUsersView: View {
    var users: [UserInfo]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recent")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.9))
                .textCase(nil)
                .padding(.leading)
                .padding(.top, 5)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(users) { user in
                        NavigationLink {
                            ProfileView(user: user)
                        } label: {
                            VStack {
                                UserPhotoView(size: 45, imagePath: user.avatar_url)
                                Text(user.name ?? "Unknown name")
                                    .font(.system(size: 12))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .truncationMode(.tail)
                            }
                        }
                        .frame(maxWidth: 60)
                        .buttonStyle(EmptyButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 65)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
    }
}

struct HomeBalanceView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var totalBalance: Double
    @Binding var balanceOwed: Double
    @Binding var balanceOwe: Double
    @Binding var transactionType: TransactionType
    
    var currentBalance: Double {
        switch transactionType {
        case .all:
            return totalBalance
        case .owed:
            return balanceOwed
        case .owe:
            return balanceOwe
        }
    }
    
    var body: some View {
        Section {
            ZStack(alignment: .bottom) {
                if colorScheme != .dark {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.32, green: 0.46, blue: 0.3), location: 0.21),
                                    Gradient.Stop(color: Color(red: 0.3, green: 0.46, blue: 0.28), location: 0.38),
                                    Gradient.Stop(color: Color(red: 0.29, green: 0.46, blue: 0.25), location: 0.45),
                                    Gradient.Stop(color: Color(red: 0.34, green: 0.52, blue: 0.31), location: 0.57),
                                    Gradient.Stop(color: Color(red: 0.41, green: 0.61, blue: 0.36), location: 0.70),
                                    Gradient.Stop(color: Color(red: 0.69, green: 0.81, blue: 0.52), location: 0.88)
                                ],
                                startPoint: UnitPoint(x: 0.5, y: -0.5),
                                endPoint: UnitPoint(x: 0.5, y: 1.29)
                            )
                            .shadow(.inner(color: .black.opacity(0.05), radius: 0, x: 0, y: -3))
                        )
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.11, green: 0.11, blue: 0.12), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.14, green: 0.15, blue: 0.14), location: 0.43),
                                    Gradient.Stop(color: Color(red: 0.14, green: 0.21, blue: 0.13), location: 0.86),
                                    Gradient.Stop(color: Color(red: 0.19, green: 0.28, blue: 0.17), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                            .shadow(.inner(color: .white.opacity(0.1), radius: 0, x: 0, y: -2))
                        )
                }
                VStack(spacing: 12) {
                    Picker("Show Transactions", selection: $transactionType) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue.localizedCapitalized).tag(type)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.primary.opacity(0.125))
                    )
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 260)
                    .onAppear {
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
                        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label], for: .selected)
                    }
                    VStack {
                        Text(currentBalance, format: .currency(code: "USD"))
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .kerning(0.96)
                            .foregroundStyle(.white
                                .shadow(.drop(color: .black.opacity(0.25), radius: 0, x: 0, y: 2)))
                            .contentTransition(.numericText())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.layoutGreen.opacity(colorScheme != .dark ? 0 : 0.3), lineWidth: 1)
                    )
                    .animation(.default, value: currentBalance)
                }
                .padding()
            }
        }
        .listRowInsets(EdgeInsets())
    }
}
