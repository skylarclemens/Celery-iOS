//
//  TransactionsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var transactionsList: [Debt]?
    @Binding var state: LoadingState
    
    var body: some View {
        List {
            Section {
                if state == .success {
                    if let transactionsList,
                       !transactionsList.isEmpty {
                        ForEach(transactionsList) { debt in
                            NavigationLink {
                                if let expense = debt.expense {
                                    ExpenseView(expense: expense)
                                        .tint(.white)
                                }
                            } label: {
                                HStack(spacing: 12) {
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
                                            .frame(maxWidth: 20, maxHeight: 20)
                                        Circle()
                                            .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 2)
                                    }
                                    .frame(width: 40, height: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(debt.expense?.description ?? "Unknown name")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text(debt.expense?.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(.tertiary)
                                    }
                                    Spacer()
                                    if let currentUser = authViewModel.currentUserInfo {
                                        let userOwed = debt.creditor?.id == currentUser.id
                                        HStack(spacing: 0) {
                                            Text(userOwed ? "+" : "-")
                                            Text(debt.amount ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                        }
                                        .foregroundStyle(!userOwed ? Color.layoutRed : Color.layoutGreen)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    }
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
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
            } header: {
                Text("Transactions")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.9))
                    .textCase(nil)
                    .padding(.bottom, 8)
                    .padding(.top, 5)
            }
        }
        .animation(.default, value: transactionsList)
    }
}

#Preview {
    NavigationStack {
        TransactionsView(transactionsList: .constant([Debt.example]), state: .constant(.success))
            .environmentObject(AuthenticationViewModel())
    }
}
