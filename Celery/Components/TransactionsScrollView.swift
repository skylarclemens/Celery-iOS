//
//  TransactionsScrollView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import SwiftUI

struct TransactionsScrollView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var transactionsList: [Debt]?
    @Binding var state: LoadingState
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Transactions")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.9))
                .textCase(nil)
                .padding(.leading)
                .padding(.bottom, 8)
                .padding(.top, 5)
            LazyVStack {
                if state == .success {
                    if let transactionsList,
                       !transactionsList.isEmpty {
                        ForEach(transactionsList) { debt in
                            TransactionView(debt: debt)
                                .tint(.primary)
                                .padding(.horizontal)
                            if debt != transactionsList.last {
                                Divider()
                                    .padding(.vertical, 6)
                                    .padding(.leading, 66)
                            }
                        }
                    } else {
                        Text("No expenses")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else if state == .loading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                } else if state == .error {
                    VStack {
                        Text("Something went wrong!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            ScrollView {
                TransactionsScrollView(transactionsList: .constant([Debt.example, Debt(id: UUID(), amount: 20.0, creditor: UserInfo.example, debtor: UserInfo.example, expense: Expense.example)]), state: .constant(.success))
                    .environmentObject(AuthenticationViewModel())
            }
        }
    }
}
