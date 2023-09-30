//
//  UserFriend.swift
//  Celery
//
//  Created by Skylar Clemens on 9/20/23.
//

import Foundation

struct UserFriend: Codable, Identifiable, Equatable {
    let id = UUID()
    let user_id: UUID?
    let friend: UserInfo?
    let status: Int?
    let status_change: Date?
}
