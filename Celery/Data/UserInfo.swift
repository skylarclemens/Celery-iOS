//
//  UserInfo.swift
//  Celery
//
//  Created by Skylar Clemens on 9/19/23.
//

import Foundation

struct UserInfo: Codable, Identifiable {
    let id: UUID
    let email: String?
    let name: String?
    let avatar_url: String?
    let updated_at: Date?
    let username: String?
    
    static let example = UserInfo(id: UUID(), email: "example@email.com", name: "Test", avatar_url: nil, updated_at: Date(), username: "test")
}
