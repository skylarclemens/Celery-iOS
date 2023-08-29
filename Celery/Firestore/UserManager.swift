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

struct UserInfo: Codable {
    let id: String
    let email: String?
    let displayName: String?
    let username: String?
    let photoUrl: URL?
    let createdAt: Date?
    
    init(auth authUser: User) {
        self.id = authUser.uid
        self.email = authUser.email
        self.displayName = authUser.displayName
        self.username = nil
        self.photoUrl = authUser.photoURL
        self.createdAt = Date()
    }
    
    init(
        id: String,
        email: String? = nil,
        displayName: String? = nil,
        username: String? = nil,
        photoUrl: URL? = nil,
        createdAt: Date
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.username = username
        self.photoUrl = photoUrl
        self.createdAt = createdAt
    }
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
}
