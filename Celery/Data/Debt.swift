//
//  Debt.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import Foundation

struct Debt: Codable {
    let amount: Double?
    let creditorID: String?
    let debtorID: String?
    let expenseID: String?
    let paid: Bool
    let groupID: String?
    let createdAt: Date
}
