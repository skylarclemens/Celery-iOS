//
//  Debt.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import Foundation

struct Debt: Codable, Identifiable {
    let id: UUID?
    let amount: Double?
    let creditor: UserInfo?
    let debtor: UserInfo?
    let expense: Expense?
    let paid: Bool?
    let group_id: String?
    let created_at: Date?
}
