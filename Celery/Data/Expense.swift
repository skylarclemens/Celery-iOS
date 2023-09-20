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
}
