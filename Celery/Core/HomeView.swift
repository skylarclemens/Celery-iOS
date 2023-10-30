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
    var maxDebtCount: Int {
        guard let debts = model.debts else { return 0 }
        if debts.count < 10 {
            return debts.count
        } else {
            return 10
        }
    }
    var filteredTransactionList: [Debt] {
        guard let debts = model.debts else { return [] }
        switch balanceType {
        case .all:
            return Array(debts[0..<maxDebtCount])
        case .owed:
            let filteredArraySlice = debts.filter {
                $0.creditor?.id == authViewModel.currentUserInfo?.id
            }[0..<maxDebtCount]
            return Array(filteredArraySlice)
        case .owe:
            let filteredArraySlice = debts.filter {
                $0.creditor?.id != authViewModel.currentUserInfo?.id
            }[0..<maxDebtCount]
            return Array(filteredArraySlice)
        }
    }
    
    var balances: Balance {
        guard let debts = model.debts else { return Balance() }
        return balanceCalc(using: debts)
    }
    
    @State var balanceType: BalanceType = .all
    
    @State var openSettings: Bool = false
    @State var transactionsState: LoadingState = .loading
    
    var body: some View {
        NavigationStack {
            ScrollView {
                HomeBalanceView(balances: balances, balanceType: $balanceType)
                    .padding(.horizontal)
                if let recentUsers = model.recentUsers,
                   let debts = model.debts {
                    VStack(alignment: .leading) {
                        Text("Recent Transactions")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .padding(.leading)
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 12) {
                                ForEach(filteredTransactionList) { debt in
                                    RecentTransaction(debt: debt)
                                }
                            }
                            .padding([.horizontal, .bottom])
                        }
                        .scrollIndicators(.hidden)
                    }
                    .padding(.top)
                    VStack(alignment: .leading) {
                        RecentUsersView(users: recentUsers, debts: debts)
                    }
                    .padding()
                    .padding(.bottom, 40)
                }
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
                SettingsView(currentUser: authViewModel.currentUserInfo)
                    .tint(.blue)
            }
        }
        .onReceive(model.$debts) { newValue in
            organizeDebt(debt: newValue)
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
    func organizeDebt(debt: [Debt]?) {
        if let debt,
           !debt.isEmpty {
            let creditors = debt.map {
                $0.creditor!
            }
            let debtors = debt.map {
                $0.debtor!
            }
            let allUsers = creditors + debtors
            let uniqueUsers = Set(allUsers)
            model.recentUsers = Array(uniqueUsers).filter {
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(Model())
    }
}


struct RecentTransaction: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var debt: Debt
    
    var body: some View {
        NavigationLink {
            if let expense = debt.expense {
                ExpenseView(expense: expense)
            }
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color(hex: Category.categoryList.first(where: {
                                $0.name == debt.expense?.category?.capitalized
                            })?.colorUInt ?? 0x6A9B5D)
                                .shadow(.inner(color: .black.opacity(0.1), radius: 10, y: -2))
                                .shadow(.drop(color: .black.opacity(0.2), radius: 2, y: 1))
                            )
                        
                        Image(debt.expense?.category?.capitalized ?? "General")
                            .resizable()
                            .frame(maxWidth: 10, maxHeight: 10)
                        Circle()
                            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 2)
                    }
                    .frame(width: 20, height: 20)
                    Text(debt.expense?.description ?? "Unknown name")
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    if let currentUser = authViewModel.currentUserInfo {
                        let userOwed = debt.creditor?.id == currentUser.id
                        HStack(spacing: 0) {
                            Text(userOwed ? "+" : "-")
                            Text(debt.amount ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        }
                        .foregroundStyle(!userOwed ? Color.layoutRed : Color.layoutGreen)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                }
                .padding(.vertical, 2)
                Divider()
                Spacer()
                HStack(spacing: -5) {
                    UserPhotoView(size: 35, imagePath: debt.creditor?.avatar_url)
                    UserPhotoView(size: 35, imagePath: debt.debtor?.avatar_url)
                }
                .padding(.vertical, 2)
                Spacer()
                Divider()
                HStack {
                    Text(debt.expense?.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 2)
            }
            .padding(8)
            .frame(height: 130)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary.opacity(colorScheme == .light ? 0.25 : 0.5), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 3)
            .frame(width: 200)
        }
        .buttonStyle(.plain)
    }
}

enum BalanceType: String, CaseIterable, Identifiable {
    case all, owed, owe
    
    var id: Self {
        return self
    }
}

struct RecentUsersView: View {
    var users: [UserInfo]
    var debts: [Debt]
    
    var body: some View {
        ForEach(users) { user in
            let sharedDebts = debts.filter {
                $0.creditor?.id == user.id || $0.debtor?.id == user.id
            }
            FriendOverviewView(debts: sharedDebts, user: user)
        }
    }
}

struct HomeBalanceView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var balances: Balance
    @Binding var balanceType: BalanceType
    
    var currentBalance: Double {
        switch balanceType {
        case .all:
            return balances.total
        case .owed:
            return balances.owed
        case .owe:
            return balances.owe
        }
    }
    
    var body: some View {
        VStack {
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
                        TransactionPicker(selected: $balanceType)
                        VStack {
                            Text(currentBalance, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
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
        }
        .listRowInsets(EdgeInsets())
    }
}

struct TransactionPicker: View {
    @Binding var selected: BalanceType
    @Namespace var namespace
    
    var body: some View {
        HStack(alignment: .center) {
            ForEach(BalanceType.allCases) { type in
                Button {
                    withAnimation {
                        selected = type
                    }
                } label: {
                    ZStack {
                        if selected == type {
                            Capsule()
                                .fill(.white
                                    .shadow(.inner(color: .black.opacity(0.05), radius: 0, y: -3))
                                )
                                .matchedGeometryEffect(id: "selectedBackground", in: namespace)
                                .animation(.default, value: selected)
                                .zIndex(1)
                                .opacity(selected == type ? 1 : 0)
                                .blendMode(.difference)
                                
                        }
                        Text(type.rawValue.localizedCapitalized).tag(type)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                    }
                    .compositingGroup()
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: 200, maxHeight: 40)
        .padding(.horizontal, 3)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .foregroundStyle(
                    .linearGradient(
                        stops: [
                        Gradient.Stop(color: .black.opacity(0.2), location: 0.13),
                        Gradient.Stop(color: Color(red: 0.42, green: 0.61, blue: 0.36).opacity(0.2), location: 0.47),
                        Gradient.Stop(color: Color(red: 0.86, green: 0.33, blue: 0.22).opacity(0.2), location: 0.85),
                    ],
                    startPoint: UnitPoint(x: 0, y: 0.5),
                    endPoint: UnitPoint(x: 1, y: 0.5))
                    .shadow(.inner(radius: 10))
                )
        )
        .background(Capsule().fill(.black.opacity(0.11)))
    }
}

#Preview {
    TransactionPicker(selected: .constant(.all))
}
