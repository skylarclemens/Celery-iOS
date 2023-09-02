//
//  UserManager.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct UserInfo: Identifiable, Codable {
    let id: String
    let email: String?
    let displayName: String?
    let displayNameLowercase: String?
    let username: String?
    let photoURL: URL?
    let createdAt: Date?
    
    init(auth authUser: User) {
        self.id = authUser.uid
        self.email = authUser.email
        self.displayName = authUser.displayName
        self.displayNameLowercase = authUser.displayName?.lowercased()
        self.username = nil
        self.photoURL = authUser.photoURL
        self.createdAt = Date()
    }
    
    init(
        id: String,
        email: String? = nil,
        displayName: String? = nil,
        displayNameLowercase: String? = nil,
        username: String? = nil,
        photoURL: URL? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.displayNameLowercase = displayName?.lowercased()
        self.username = username
        self.photoURL = photoURL
        self.createdAt = createdAt
    }
    
    static var example = UserInfo(id: UUID().uuidString, email: "example@email.com", displayName: "Tracy", username: "moonshinetrace", createdAt: Date())
}

final class UserManager {
    static let shared = UserManager()
    private init() {}
    
    private let collection = Firestore.firestore().collection("users")
    private func userDocument(_ userId: String) -> DocumentReference { collection.document(userId) }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    func createNewUser(user: UserInfo) async throws {
        try userDocument(user.id).setData(from: user, merge: false, encoder: encoder)
    }
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func getUser(userId: String) async throws -> UserInfo {
        try await userDocument(userId).getDocument(as: UserInfo.self, decoder: decoder)
    }
    
    func getFriendsUserInfo(friendIds: [String], limit: Int, startAt: Int = 0) async throws -> [UserInfo]? {
        guard friendIds.count > 0 else { return nil }
        var friendsInfo: [UserInfo] = []
        let setLimit = friendIds.count < limit ? friendIds.count : limit
        for i in startAt..<setLimit {
            let friendId = friendIds[i]
            let friend = try await getUser(userId: friendId)
            friendsInfo.append(friend)
        }
        return friendsInfo
    }
    
    func getUsers(matching keyword: String) async throws -> [UserInfo] {
        let users = try await collection
            .whereField("display_name_lowercase", isGreaterThanOrEqualTo: keyword.lowercased())
            .whereField("display_name_lowercase", isLessThanOrEqualTo: keyword.lowercased()+"\u{F7FF}")
            .getDocuments(as: UserInfo.self, decoder: decoder)
        return users
    }
}

extension Query {
    func getDocuments<T>(as type: T.Type, decoder: Firestore.Decoder? = nil) async throws -> [T] where T: Decodable {
        let snapshot = try await self.getDocuments()
        return try snapshot.documents.map({ document in
            if let decoder {
                try document.data(as: T.self, decoder: decoder)
            } else {
                try document.data(as: T.self)
            }
        })
    }
}