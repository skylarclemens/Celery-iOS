//
//  PayView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/1/23.
//

import SwiftUI

struct PayView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    var creditor: UserInfo?
    var debtor: UserInfo?
    var debts: [Debt]?
    var amount: Double?
    @State var expenseDebts: [Debt]?
    @State var submitState: LoadingState?
    
    private let currencyFormat: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 4) {
                    HStack(spacing: 16) {
                        UserPhotoView(size: 72, imagePath: debtor?.avatar_url)
                        UserPhotoView(size: 72, imagePath: creditor?.avatar_url)
                    }
                    .padding(.bottom, 8)
                    Group {
                        if let debtor,
                           let creditor {
                            Text(authViewModel.isCurrentUser(userId: debtor.id) ? "You" : (debtor.name ?? "Unknown user"))
                                .fontWeight(.medium) +
                            Text(" paid ") +
                            Text(authViewModel.isCurrentUser(userId: creditor.id) ? "you" : (creditor.name ?? "Unknown user"))
                                .fontWeight(.medium)
                        }
                    }.font(.system(size: 24))
                    if let amount {
                        Text(amount, format: currencyFormat)
                            .font(.system(size: 36, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.layoutGreen)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: UIColor.tertiarySystemGroupedBackground))
            )
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 8)
            Group {
                Button {
                    Task {
                        await handlePay()
                        dismiss()
                    }
                } label: {
                    if let submitState,
                       submitState == .loading {
                        ProgressView()
                            .tint(.white)
                            .controlSize(.regular)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Confirm")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.layoutGreen, lineWidth: 1))
                .padding(.top, 8)
                .tint(.primaryAction)
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .padding(.vertical, 8)
                        .foregroundStyle(submitState == .loading ? Color(UIColor.tertiaryLabel) : Color.secondary)
                }
                .disabled(submitState == .loading)
            }
            .padding(.horizontal)
        }
    }
}

extension PayView {
    func handlePay() async {
        self.submitState = .loading
        let updatedDebts = debts?.map { debt in
            Debt(id: debt.id, amount: debt.amount, creditor: debt.creditor, debtor: debt.debtor, expense: debt.expense, paid: true, group_id: debt.group_id, created_at: debt.created_at)
        }
        
        let expenses = debts?.compactMap {
            $0.expense
        }
        guard let expenses else { return }
       
        let expenseIds = expenses.map {
            $0.id
        }

        await fetchAllExpenseDebts(expenseIds: expenseIds)

        var allDebtsUpdated: [Debt] = []
        if let expenseDebts = self.expenseDebts {
            allDebtsUpdated = expenseDebts.map { debt in
                let checkUsers = debt.creditor?.id == self.creditor?.id && debt.debtor?.id == self.debtor?.id
                let checkUsers2 = debt.debtor?.id == self.creditor?.id && debt.creditor?.id == self.debtor?.id
                if checkUsers || checkUsers2 {
                    return Debt(id: debt.id, amount: debt.amount, creditor: debt.creditor, debtor: debt.debtor, expense: debt.expense, paid: true, group_id: debt.group_id, created_at: debt.created_at)
                } else {
                    return debt
                }
            }
        }
        
        let updatedExpenses = expenses.compactMap { expense in
            if markExpensePaid(expense: expense, debts: allDebtsUpdated) {
                return Expense(id: expense.id, paid: true, description: expense.description, amount: expense.amount, payer_id: expense.payer_id, group_id: expense.group_id, category: expense.category, date: expense.date, created_at: expense.created_at)
            } else {
                return nil
            }
        }
        
        var updatedDebtModels: [DebtModel] = []
        if let updatedDebts {
            updatedDebtModels = updatedDebts.map { debt in
                DebtModel(id: debt.id, amount: debt.amount, creditor_id: debt.creditor?.id, debtor_id: debt.debtor?.id, expense_id: debt.expense?.id, paid: true, group_id: debt.group_id, created_at: debt.created_at)
            }
        }
        
        await updateDebtsAndExpenses(debts: updatedDebtModels, expenses: updatedExpenses)
        
        let newDebtActivities: [Activity] = updatedDebtModels.map { debt in
            if let debtor_id = debt.debtor_id,
                authViewModel.isCurrentUser(userId: debtor_id) {
                return Activity(user_id: debt.creditor_id, reference_id: debt.id, type: .debt, action: .settle, related_user_id: debt.debtor_id)
            } else {
                return Activity(user_id: debt.debtor_id, reference_id: debt.id, type: .debt, action: .pay, related_user_id: debt.creditor_id)
            }
        }
        
        let newExpenseActivites: [Activity] = updatedExpenses.map { expense in
            Activity(user_id: expense.payer_id, reference_id: expense.id, type: .expense, action: .pay)
        }

        await addNewActivities(activities: newDebtActivities)
        await addNewActivities(activities: newExpenseActivites)
        
        self.submitState = .success
    }
    
    func updateDebtsAndExpenses(debts: [DebtModel], expenses: [Expense]) async {
        try? await SupabaseManager.shared.updateDebts(debts)
        try? await SupabaseManager.shared.updateExpenses(expenses)
    }
    
    func addNewActivities(activities: [Activity]) async {
        try? await SupabaseManager.shared.addNewActivities(activities)
    }
    
    func fetchAllExpenseDebts(expenseIds: [UUID]) async {
        self.expenseDebts = try? await SupabaseManager.shared.getDebtsByExpenseIds(expenseIds: expenseIds)
    }
    
    func markExpensePaid(expense: Expense, debts: [Debt]) -> Bool {
        let unpaidDebts = debts.filter { debt in
            debt.expense?.id == expense.id && !(debt.paid ?? false)
        }
        if unpaidDebts.isEmpty {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    VStack {
        
    }
    .sheet(isPresented: .constant(true)) {
        PayView(amount: 10.0)
            .presentationDetents([.medium])
    }
}
