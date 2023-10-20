//
//  Payment.swift
//  Celery
//
//  Created by Skylar Clemens on 10/20/23.
//

import Foundation

struct Payment: Codable, Identifiable {
    let id: Int?
    let created_at: Date?
    let recipient_id: UUID?
    let payer_id: UUID?
    let group_id: UUID?
    let debt_id: UUID?
    let amount: Double?
}
