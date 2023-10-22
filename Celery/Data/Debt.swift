//
//  Debt.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import Foundation

struct Debt: Codable, Identifiable, Equatable {
    static func == (lhs: Debt, rhs: Debt) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID?
    let amount: Double?
    let creditor: UserInfo?
    let debtor: UserInfo?
    let expense: Expense?
    let paid: Bool?
    let group_id: UUID?
    let created_at: Date?
    
    init(id: UUID? = nil, amount: Double?, creditor: UserInfo?, debtor: UserInfo?, expense: Expense?, paid: Bool? = false, group_id: UUID? = nil, created_at: Date? = nil) {
        self.id = id
        self.amount = amount
        self.creditor = creditor
        self.debtor = debtor
        self.expense = expense
        self.paid = paid
        self.group_id = group_id
        self.created_at = created_at
    }
    
    var expenseDate: Date {
        if let expense,
           let date = expense.date {
            return date
        } else {
            return Date()
        }
    }
    
    static let example = Debt(id: UUID(), amount: 10.00, creditor: UserInfo.example, debtor: nil, expense: Expense.example, paid: false, group_id: nil, created_at: Date())
}

struct DebtModel: Codable, Identifiable {
    let id: UUID?
    let amount: Double?
    let creditor_id: UUID?
    let debtor_id: UUID?
    let expense_id: UUID?
    let paid: Bool?
    let group_id: UUID?
    let created_at: Date?
    
    init(id: UUID? = nil, amount: Double?, creditor_id: UUID?, debtor_id: UUID?, expense_id: UUID?, paid: Bool? = false, group_id: UUID? = nil, created_at: Date? = nil) {
        self.id = id
        self.amount = amount
        self.creditor_id = creditor_id
        self.debtor_id = debtor_id
        self.expense_id = expense_id
        self.paid = paid
        self.group_id = group_id
        self.created_at = created_at
    }
}
