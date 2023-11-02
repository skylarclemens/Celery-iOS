//
//  Expense.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import Foundation
import SwiftUI

struct Expense: Codable, Identifiable, Hashable {
    let id: UUID
    let paid: Bool?
    let description: String?
    let amount: Double?
    let payer_id: UUID?
    let group_id: UUID?
    let category: String?
    let date: Date?
    let created_at: Date?
    
    var categoryColor: Color {
        Category.categoryList.first(where: {
            $0.name == self.category?.capitalized
        })?.color ?? Color("green")
    }
    
    init(id: UUID, paid: Bool? = false, description: String?, amount: Double?, payer_id: UUID?, group_id: UUID? = nil, category: String?, date: Date?, created_at: Date? = nil) {
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
    
    static let example = Expense(id: UUID(), paid: false, description: "Example", amount: 10.00, payer_id: UserInfo.example.id, category: "Entertainment", date: Date(), created_at: Date())
}
