//
//  Activity.swift
//  Celery
//
//  Created by Skylar Clemens on 9/28/23.
//

import Foundation

struct Activity: Codable, Identifiable {
    let id: Int?
    let user_id: UUID?
    let reference_id: UUID?
    let type: ActivityType?
    let action: ActivityAction?
    let related_user_id: UUID?
    let created_at: Date?
    
    init(id: Int? = nil, user_id: UUID?, reference_id: UUID?, type: ActivityType?, action: ActivityAction?, related_user_id: UUID? = nil, created_at: Date? = nil) {
        self.id = id
        self.user_id = user_id
        self.reference_id = reference_id
        self.type = type
        self.action = action
        self.related_user_id = related_user_id
        self.created_at = created_at
    }
}

enum ActivityType: String, Codable {
    case expense = "EXPENSE"
    case debt = "DEBT"
    case group = "GROUP"
}

enum ActivityAction: String, Codable {
    case create = "CREATE"
    case update = "UPDATE"
    case delete = "DELETE"
    case pay = "PAY"
    case settle = "SETTLE"
}
