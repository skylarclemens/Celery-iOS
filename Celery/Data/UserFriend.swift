//
//  UserFriend.swift
//  Celery
//
//  Created by Skylar Clemens on 9/20/23.
//

import Foundation

struct UserFriend: Codable, Identifiable, Equatable {
    let id = UUID()
    let user: UserInfo?
    let friend: UserInfo?
    let status: Int?
    let status_change: Date?
    
    static var example = UserFriend(user: UserInfo.example, friend: UserInfo.example, status: 0, status_change: nil)
}

struct UserFriendModel: Codable {
    let user_id: UUID?
    let friend_id: UUID?
    let status: Int?
    let status_change: Date?
}
