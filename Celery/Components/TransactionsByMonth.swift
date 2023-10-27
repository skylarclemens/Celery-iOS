//
//  TransactionsByMonth.swift
//  Celery
//
//  Created by Skylar Clemens on 10/22/23.
//

import SwiftUI

struct TransactionsByMonth: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let transactionsList: [Debt]
    @Binding var state: LoadingState

    var groupedByMonth: [DateComponents: [Debt]] {
        Dictionary(grouping: transactionsList) { debt in
            Calendar.current.dateComponents([.month, .year], from: debt.expenseDate)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
                if state == .success {
                    if !groupedByMonth.isEmpty {
                        LazyVStack(spacing: 12) {
                            ForEach(groupedByMonth.sorted(by: { $0.key > $1.key }), id: \.key) { key, value in
                                let monthName = DateFormatter().monthSymbols[(key.month ?? 0) - 1]
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(monthName)
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(.leading)
                                        .padding(.bottom, 4)
                                    ForEach(value) { debt in
                                        VStack(spacing: 0) {
                                            Spacer()
                                            TransactionView(debt: debt)
                                                .tint(.primary)
                                                .padding(.horizontal)
                                            Spacer()
                                            if debt != value.last {
                                                Divider()
                                                    .padding(.leading, 66)
                                            }
                                        }
                                        .frame(height: 70)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    } else {
                        Text("No expenses")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
        ScrollView {
            TransactionsByMonth(transactionsList: [Debt.example, Debt(id: UUID(), amount: 20.0, creditor: UserInfo.example, debtor: UserInfo.example, expense: Expense.example)], state: .constant(.success))
                .environmentObject(AuthenticationViewModel())
        }
    }
}

extension Date {
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
}

extension DateComponents: Comparable {
    public static func < (lhs: DateComponents, rhs: DateComponents) -> Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        return calendar.date(byAdding: lhs, to: currentDate)! < calendar.date(byAdding: rhs, to: currentDate)!
    }
}
