//
//  SupabaseManager.swift
//  Celery
//
//  Created by Skylar Clemens on 9/19/23.
//

import Foundation
import Supabase
import UIKit

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    init() {
        let SUPABASE_URL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        let SUPABASE_API_KEY = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_API_KEY") as? String ?? ""
        
        self.client = SupabaseClient(supabaseURL: URL(fileURLWithPath: SUPABASE_URL), supabaseKey: SUPABASE_API_KEY)
    }
    
    func getUser(userId: UUID) async throws -> UserInfo? {
        do {
            let user: [UserInfo] = try await client.database.from("users")
                .select()
                .eq(column: "id", value: userId)
                .limit(count: 1)
                .execute()
                .value
            /*let response = try await client.database.from("users")
                .select()
                .eq(column: "id", value: userId)
                .execute()
            print(String(data: response.underlyingResponse.data, encoding: .utf8))*/
            return user.first
        } catch {
            print(error)
            return nil
        }
    }
    
    // Retrieve user's avatar image from Supabase storage
    func getAvatarImage(imagePath: String, completion: @escaping (UIImage?) -> Void) async throws {
        do {
            let storageRef = try await self.client.storage
                .from(id: "avatars")
                .download(path: imagePath)
            completion(UIImage(data: storageRef))
        } catch {
            completion(nil)
            print(error)
        }
    }
    
    // Get current user's list of friends
    func getUsersFriends() async throws -> [UserFriendModel]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let friendsList: [UserFriendModel] = try await self.client.database.from("user_friend")
                .select(columns: """
                *,
                friend: friend_id(*)
                """)
                .eq(column: "user_id", value: currentUserId)
                .eq(column: "status", value: 1)
                .execute()
                .value
            return friendsList
        } catch {
            print("Error fetching friends: \(error)")
            return nil
        }
    }
}
