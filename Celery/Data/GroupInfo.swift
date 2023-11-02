//
//  GroupInfo.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import Foundation
import SwiftUI

struct GroupInfo: Codable, Identifiable, Hashable {
    let id: UUID
    let group_name: String?
    let created_at: Date?
    let avatar_url: String?
    let color: String?
    let members: [UserInfo]?
    
    static let example = GroupInfo(id: UUID(uuidString: "7fbbac50-6f81-4735-8531-2a3c338f260d")!, group_name: "Test group", created_at: Date(), avatar_url: nil, color: nil, members: [UserInfo.example])
}

struct GroupModel: Codable, Identifiable, Hashable {
    let id: UUID
    let group_name: String?
    let created_at: Date?
    let avatar_url: String?
    let color: String?
}

struct UserGroupModel: Codable {
    let user_id: UUID
    let group_id: UUID
}
