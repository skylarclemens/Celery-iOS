//
//  TransactionsScrollView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import SwiftUI

struct TransactionsScrollView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let transactionsList: [Debt]
    @Binding var state: LoadingState
    
    var body: some View {
        VStack(alignment: .leading) {
            LazyVStack(spacing: 0) {
                if state == .success {
                    if !transactionsList.isEmpty {
                        ForEach(transactionsList) { debt in
                            VStack {
                                Spacer()
                                TransactionView(debt: debt)
                                    .tint(.primary)
                                    .padding(.horizontal)
                                Spacer()
                                if debt != transactionsList.last {
                                    Divider()
                                        .padding(.leading, 66)
                                }
                            }
                            .frame(height: 60)
                        }
                    } else {
                        Text("No expenses")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                } else if state == .loading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                } else if state == .error {
                    VStack {
                        Text("Something went wrong!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            ScrollView {
                TransactionsScrollView(transactionsList: [Debt.example, Debt(id: UUID(), amount: 20.0, creditor: UserInfo.example, debtor: UserInfo.example, expense: Expense.example)], state: .constant(.success))
                    .environmentObject(AuthenticationViewModel())
            }
        }
    }
}
