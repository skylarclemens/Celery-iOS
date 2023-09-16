//
//  TransactionsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var userExpenses: [Expense]?
    
    func getUserExpenses(userId: String) async throws {
        self.userExpenses = try? await ExpenseManager.shared.getUsersExpenses(userId: userId)
    }
}

struct TransactionsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var viewModel = TransactionsViewModel()
    
    var body: some View {
        List {
            Section {
                if let fetchedExpenses = viewModel.userExpenses,
                   !fetchedExpenses.isEmpty {
                    ForEach(fetchedExpenses) { expense in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: Category.categoryList[expense.category ?? "Category"]?.colorUInt ?? 0x6A9B5D)
                                        .shadow(.inner(color: .black.opacity(0.1), radius: 10, y: -2))
                                        .shadow(.drop(color: .black.opacity(0.2), radius: 2, y: 1))
                                    )
                                    
                                Image(expense.category ?? "Category")
                                    .resizable()
                                    .frame(maxWidth: 20, maxHeight: 20)
                                Circle()
                                    //.inset(by: -1)
                                    .stroke(.background, lineWidth: 2)
                            }
                            .frame(width: 40, height: 40)
                            VStack(alignment: .leading) {
                                Text(expense.name ?? "Unknown name")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 0) {
                                Text("+")
                                Text(expense.amount ?? 0, format: .currency(code: "USD"))
                            }
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.42, green: 0.61, blue: 0.36), Color(red: 0.37, green: 0.55, blue: 0.33)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No expenses")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Transactions")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .textCase(nil)
                    .padding(.bottom, 8)
            }
        }
        .task {
            try? await viewModel.getUserExpenses(userId: authViewModel.currentUser?.uid ?? "")
        }
    }
}

#Preview {
    TransactionsView()
        .environmentObject(AuthenticationViewModel())
}
