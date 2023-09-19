//
//  Debt.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import Foundation

struct DebtModel: Codable, Identifiable {
    let id: UUID?
    let amount: Double?
    let creditor_id: String?
    let debtor_id: String?
    let expense: ExpenseModel?
    let paid: Bool?
    let group_id: String?
    let created_at: Date?
}
