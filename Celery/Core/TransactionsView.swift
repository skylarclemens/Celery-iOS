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
    
    /*func getUserExpenses(userId: String) async throws {
        self.userExpenses = try? await ExpenseManager.shared.getUsersExpenses(userId: userId)
    }*/
}

struct TransactionsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var viewModel = TransactionsViewModel()
    @State var transactionsList: [Debt]?
    @State var userId: String = ""
    
    var body: some View {
        List {
            Section {
                if let transactionsList,
                   !transactionsList.isEmpty{
                    ForEach(transactionsList) { debt in
                        let userOwed = debt.creditor?.id.uuidString.uppercased() == userId.uppercased()
                        NavigationLink {
                            if let expense = debt.expense {
                                ExpenseView(expense: expense)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: Category.categoryList[debt.expense?.category?.capitalized ?? "General"]?.colorUInt ?? 0x6A9B5D)
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
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(debt.expense?.description ?? "Unknown name")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(debt.expense?.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.tertiary)
                                }
                                Spacer()
                                HStack(spacing: 0) {
                                    Text(userOwed ? "+" : "-")
                                    Text(debt.amount ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                }
                                .foregroundStyle(!userOwed ? Color.layoutRed : Color.layoutGreen)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    }
                } else {
                    Text("No expenses")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Transactions")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.9))
                    .textCase(nil)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            Task {
                self.transactionsList = try await SupabaseManager.shared.getDebtsWithExpense()
                if let id = authViewModel.currentUserInfo?.id.uuidString {
                    self.userId = id
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionsView()
            .environmentObject(AuthenticationViewModel())
    }
}
