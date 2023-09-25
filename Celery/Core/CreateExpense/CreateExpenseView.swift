//
//  CreateExpenseView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

class NewExpense: ObservableObject {
    @Published var name: String = ""
    @Published var amount: Double = 0.0
    @Published var date: Date = Date()
    @Published var paidBy: String = "None"
    @Published var category: String = "Category"
    @Published var splitWith: [UserInfo] = []
    
    @Published var currentTabIndex: Int = 0
}

struct CreateExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var newExpense = NewExpense()
    
    /*@State private var name: String = ""
    @State private var amount: Double = 0.0
    let currencyFormatter: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    @State private var date = Date()
    @State private var paidBy: String = "None"
    @State private var category: String = "Category"
    @State private var splitWith: [UserInfo] = []*/
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea()
                TabView(selection: $newExpense.currentTabIndex) {
                    CreateExpenseDetailsView(newExpense: newExpense)
                        .tag(0)
                    CreateExpenseSplitView(newExpense: newExpense)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeOut, value: newExpense.currentTabIndex)
                .transition(.slide)
            }
        }
    }
    
    /*func createNewExpense() async throws {
        do {
            let selectedCategory = category == "Category" ? "General" : category
            /*let newExpense = Expense(id: UUID().uuidString, name: name, description: nil, amount: amount, payerID: authViewModel.currentUser?.uid ?? nil, groupID: nil, category: selectedCategory, date: date, createdAt: Date())
            try await ExpenseManager.shared.createNewExpense(expense: newExpense)*/
        } catch {
            print(error)
        }
    }*/
}

#Preview {
    CreateExpenseView()
        .environmentObject(AuthenticationViewModel())
}
