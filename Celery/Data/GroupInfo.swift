//
//  GroupInfo.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import Foundation

struct GroupInfo: Codable, Identifiable, Hashable {
    let id: UUID
    let group_name: String?
    let created_at: Date?
    let avatar_url: String?
    let color: String?
    
    static let example = GroupInfo(id: UUID(uuidString: "7fbbac50-6f81-4735-8531-2a3c338f260d")!, group_name: "Test group", created_at: Date(), avatar_url: "B1133FD5-7840-4A18-BFB3-18439BFEE95E/A05640FC-3728-4193-9E0B-BCB6F4818141", color: nil)
}

struct UserGroupModel: Codable {
    let user_id: UUID
    let group_id: UUID
}
