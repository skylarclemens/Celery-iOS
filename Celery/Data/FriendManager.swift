//
//  FriendManager.swift
//  Celery
//
//  Created by Skylar Clemens on 8/30/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct Friendship: Codable, Hashable {
    let user1: String
    let user2: String
    let status: Int
    var userIdsString: String {
        "\(user1)+\(user2)"
    }
    var userIdsArray: [String] {
        [user1, user2]
    }
}

final class FriendManager {
    static let shared = FriendManager()
    
    private init() {}
    
    private let collection = Firestore.firestore().collection("friends")
    private func friendDocument(_ userIds: String) -> DocumentReference { collection.document(userIds) }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewFriendship(friendship: Friendship) async throws {
        try friendDocument(friendship.userIdsString).setData(from: friendship, merge: false, encoder: encoder)
    }
    
    func getFriendship(userIds: [String]) async throws -> Friendship? {
        try await collection.whereFilter(Filter.andFilter([
            Filter.whereField("user1", in: userIds),
            Filter.whereField("user2", in: userIds)
        ])).getDocuments(as: Friendship.self, decoder: decoder).first
    }
    
    func getUsersFriendships(userId: String) async throws -> [Friendship]? {
        try await collection.whereFilter(Filter.orFilter([
            Filter.whereField("user1", isEqualTo: userId),
            Filter.whereField("user2", isEqualTo: userId)
        ])).getDocuments(as: Friendship.self, decoder: decoder)
    }
    
    func getFriendsIds(currentUser: UserInfo, friends: [Friendship]) -> [String] {
        var friendIds: [String] = []
        for friend in friends {
            let friendId = friend.userIdsArray.first(where: { $0 != currentUser.id })
            if let friendId {
                friendIds.append(friendId)
            }
        }
        return friendIds
    }
    
    func updateFriendship(friendship: Friendship) async throws {
        try friendDocument(friendship.userIdsString).setData(from: friendship, merge: true, encoder: encoder)
    }
}
