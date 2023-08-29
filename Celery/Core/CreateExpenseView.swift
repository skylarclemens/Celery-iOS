//
//  CreateExpenseView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

struct CreateExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @State private var name: String = ""
    @State private var amount: Double = 0
    @State private var currency: String = "USD"
    @State private var date = Date()
    @State private var paidBy: String = "None"
    var body: some View {
        Form {
            Section("Name") {
                TextField("Expense name", text: $name)
            }
            Section("Amount") {
                TextField("Amount", value: $amount, format: .currency(code: currency))
            }
            Section {
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            Section {
                Picker("Paid by", selection: $paidBy) {
                    Text("None")
                    Text("Me").tag(authViewModel.currentUser?.uid ?? "")
                }
            }
            Section {
                Button("Create") {
                    Task {
                        try await createNewExpense()
                    }
                }
                .frame(maxWidth: .infinity)
                .font(.headline)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }.listRowBackground(Color(UIColor.systemGroupedBackground))
        }
    }
    
    func createNewExpense() async throws {
        do {
            let newExpense = Expense(id: UUID().uuidString, name: name, description: nil, amount: amount, payerID: paidBy, groupID: nil, category: nil, date: date, createdAt: Date())
            try await ExpenseManager.shared.createNewExpense(expense: newExpense)
        } catch {
            print(error)
        }
    }
}

#Preview {
    CreateExpenseView()
        .environmentObject(AuthenticationViewModel())
}
