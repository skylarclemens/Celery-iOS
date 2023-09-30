//
//  Expense.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import Foundation

struct Expense: Codable, Identifiable {
    let id: UUID?
    let paid: Bool?
    let description: String?
    let amount: Double?
    let payer_id: String?
    let group_id: String?
    let category: String?
    let date: Date?
    let created_at: Date?
    
    init(id: UUID? = nil, paid: Bool? = false, description: String?, amount: Double?, payer_id: String?, group_id: String? = nil, category: String?, date: Date?, created_at: Date? = nil) {
        self.id = id
        self.paid = paid
        self.description = description
        self.amount = amount
        self.payer_id = payer_id
        self.group_id = group_id
        self.category = category
        self.date = date
        self.created_at = created_at
    }
    
    static let example = Expense(id: UUID(), paid: false, description: "Example", amount: 10.00, payer_id: UserInfo.example.id.uuidString, category: "Entertainment", date: Date(), created_at: Date())
}
