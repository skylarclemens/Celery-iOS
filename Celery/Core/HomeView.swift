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
    @State var transactionsList: [Debt]?
    @State var filteredTransactionList: [Debt]?
    @State var currentUser: UserInfo?
    
    @State var totalBalance = 0.00
    @State var balanceOwed = 0.00
    @State var balanceOwe = 0.00
    
    @State var transactionType: TransactionType = .all
    
    @State var openSettings: Bool = false
    @State var transactionsState: LoadingState = .loading
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HomeBalanceView(totalBalance: $totalBalance, balanceOwed: $balanceOwed, balanceOwe: $balanceOwe, transactionType: $transactionType)
                    .onChange(of: transactionType) { newValue in
                        switch newValue {
                        case .all:
                            self.filteredTransactionList = transactionsList
                        case .owed:
                            self.filteredTransactionList = transactionsList?.filter {
                                $0.creditor?.id == currentUser?.id
                            }
                        case .owe:
                            self.filteredTransactionList = transactionsList?.filter {
                                $0.creditor?.id != currentUser?.id
                            }
                        }
                    }
                TransactionsView(transactionsList: $filteredTransactionList, state: $transactionsState)
                    .refreshable {
                        try? await loadTransactions()
                    }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        openSettings = true
                    } label: {
                        if let currentUser {
                            UserPhotoView(size: 28, imagePath: currentUser.avatar_url)
                        } else {
                            Image(systemName: "person.crop.circle")
                                .foregroundColor(.white)
                        }
                    }
                    .accessibilityLabel("Open user settings")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    
                }
            }
            .sheet(isPresented: $openSettings) {
                UserSettingsView()
            }
        }
        .tint(.white)
        .task {
            try? await loadData()
        }
        .onAppear {
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
        }
        .onDisappear {
            UINavigationBar.appearance().titleTextAttributes = nil
        }
    }
    
    func loadData() async throws {
        if self.currentUser == nil {
            self.currentUser = try? await authViewModel.getCurrentUserInfo()
        }
        self.transactionsState = .loading
        if self.transactionsList == nil {
            try? await loadTransactions()
        } else {
            self.transactionsState = .success
        }
    }
    
    func loadTransactions() async throws {
        do {
            self.transactionsList = try await SupabaseManager.shared.getDebtsWithExpense()
            self.filteredTransactionList = self.transactionsList
            self.transactionsState = .success
            balanceCalc()
        } catch {
            self.transactionsState = .error
        }
    }
    
    func balanceCalc() {
        var totalBalance = 0.00
        var balanceOwed = 0.00
        var balanceOwe = 0.00
        if let transactionsList = self.transactionsList,
           let currentUser = self.currentUser {
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
    }
}

enum TransactionType: String, CaseIterable, Identifiable {
    case all, owed, owe
    
    var id: Self {
        return self
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
        ZStack {
            Rectangle()
                .fill(Color(uiColor: UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            if colorScheme != .dark {
                Rectangle()
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
                    .roundedCorners(24, corners: [.bottomLeft, .bottomRight])
                    .ignoresSafeArea()
            } else {
                Rectangle()
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
                    .roundedCorners(24, corners: [.bottomLeft, .bottomRight])
                    .ignoresSafeArea()
            }
            VStack {
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
                .frame(maxWidth: 200)
                .onAppear {
                    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
                    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.label], for: .selected)
                }
                VStack {
                    Text(currentBalance, format: .currency(code: "USD"))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .kerning(0.96)
                        .foregroundStyle(.white
                            .shadow(.drop(color: .black.opacity(0.25), radius: 0, x: 0, y: 2)))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background(.black.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.layoutGreen.opacity(colorScheme != .dark ? 0 : 0.3), lineWidth: 1)
                )
            }
        }
        .frame(maxHeight: 120)
    }
}
