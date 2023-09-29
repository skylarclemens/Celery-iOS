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
    @Published var paidBy: UserInfo?
    @Published var category: String = "Category"
    @Published var selectedSplit: SplitOption = .equal
    @Published var splitWith: [UserInfo] = [] {
        didSet {
            splitWith.forEach { user in
                if userAmounts[user.id] == nil {
                    userAmounts[user.id] = 0.0
                }
            }
            calcSplit()
        }
    }
    
    @Published var userAmounts: [UUID:Double] = [:]
    
    func calcSplit() {
        splitWith.forEach { user in
            if userAmounts[user.id] != nil {
                switch selectedSplit {
                case .equal:
                    userAmounts[user.id] = amount / Double(splitWith.count)
                case .exact: return
                }
            }
        }
    }
}

struct UserSplit: Identifiable {
    var user: UserInfo
    var id: UUID {
        return user.id
    }
    var amount: Double = 0.0
    var percent: Double = 0.0
    
    static func == (lhs: UserSplit, rhs: UserSplit) -> Bool {
        lhs.id == rhs.id
    }
}

struct CreateExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @StateObject var newExpense = NewExpense()
    @State var currentUser: UserInfo?
    
    var body: some View {
        NavigationStack {
            CreateExpenseDetailsView(newExpense: newExpense, currentUser: currentUser)
        }
        .onAppear {
            if newExpense.splitWith.isEmpty,
               let currentUserInfo = authViewModel.currentUserInfo {
                self.currentUser = currentUserInfo
                newExpense.splitWith.append(currentUserInfo)
            }
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.label
            ]
        }
        .onDisappear {
            UINavigationBar.appearance().titleTextAttributes = nil
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
