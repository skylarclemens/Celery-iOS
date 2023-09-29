//
//  Activity.swift
//  Celery
//
//  Created by Skylar Clemens on 9/28/23.
//

import Foundation

struct Activity: Codable, Identifiable {
    let id: Int?
    let created_at: Date?
    let user_id: UUID?
    let reference_id: UUID?
    let type: String?
    let action: String?
    let related_user_id: UUID?
    
    init(id: Int? = nil, created_at: Date? = nil, user_id: UUID?, reference_id: UUID?, type: String?, action: String?, related_user_id: UUID? = nil) {
        self.id = id
        self.created_at = created_at
        self.user_id = user_id
        self.reference_id = reference_id
        self.type = type
        self.action = action
        self.related_user_id = related_user_id
    }
}
