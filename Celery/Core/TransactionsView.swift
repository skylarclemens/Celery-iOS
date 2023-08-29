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
                if let fetchedExpenses = viewModel.userExpenses {
                    ForEach(fetchedExpenses) { expense in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.name ?? "Unknown name")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                Text(expense.date ?? Date(), style: .date)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            HStack(spacing: 0) {
                                Text("+")
                                Text(expense.amount ?? 0, format: .currency(code: "USD"))
                            }
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.42, green: 0.61, blue: 0.36))
                        }
                        .padding(.vertical, 8)
                    }
                }
            } header: {
                Text("Transactions")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
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
