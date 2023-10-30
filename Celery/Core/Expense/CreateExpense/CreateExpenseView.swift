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
    @Published var selectedGroup: GroupInfo?
    
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
    @Binding var isOpen: Bool
    
    var body: some View {
        NavigationStack {
            CreateExpenseDetailsView(newExpense: newExpense, currentUser: currentUser, isOpen: $isOpen)
        }
        .tint(.primary)
        .onAppear {
            if newExpense.splitWith.isEmpty,
               let currentUserInfo = authViewModel.currentUserInfo {
                self.currentUser = currentUserInfo
                newExpense.splitWith.append(currentUserInfo)
            }
        }
    }
}

#Preview {
    CreateExpenseView(isOpen: .constant(true))
        .environmentObject(AuthenticationViewModel())
}
