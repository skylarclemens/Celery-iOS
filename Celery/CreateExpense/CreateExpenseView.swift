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
}

#Preview {
    CreateExpenseView()
        .environmentObject(AuthenticationViewModel())
}
