//
//  UserSupabaseManager.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import Foundation

extension SupabaseManager {
    func getUser(userId: UUID) async throws -> UserInfo? {
        do {
            let user: [UserInfo] = try await client.database.from("users")
                .select()
                .eq(column: "id", value: userId)
                .limit(count: 1)
                .execute()
                .value
            return user.first
        } catch {
            print(error)
            return nil
        }
    }
    
    // Get current user's list of friends
    func getUsersFriends() async throws -> [UserFriend]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let friendsList: [UserFriend] = try await self.client.database.from("user_friend")
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
    
    // Get friendship between current user and friendId
    func getFriendship(friendId: UUID) async throws -> UserFriend? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let friend: [UserFriend] = try await self.client.database.from("user_friend")
                .select(columns: """
                *,
                friend: friend_id(*)
                """)
                .eq(column: "user_id", value: currentUserId)
                .eq(column: "friend_id", value: friendId)
                .eq(column: "status", value: 1)
                .execute()
                .value
            return friend.first
        } catch {
            print("Error fetching friend: \(error)")
            return nil
        }
    }
    
    // Get all users by query
    func getUsersByQuery(value: String) async throws -> [UserInfo]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let queriedUsers: [UserInfo] = try await self.client.database.from("users")
                .select()
                .neq(column: "id", value: currentUserId)
                .or(filters: "email.ilike.%\(value)%,name.ilike.%\(value)%,username.ilike.%\(value)%")
                .execute()
                .value
            return queriedUsers
        } catch {
            print("Error fetching users: \(error)")
            return nil
        }
    }
    
    // Update current user's information
    func updateUserInfo(user: UserInfo) async throws -> UserInfo? {
        do {
            let updatedUser: [UserInfo] = try await self.client.database.from("users")
                .update(values: user)
                .eq(column: "id", value: user.id)
                .execute()
                .value
            return updatedUser.first
        } catch {
            print("Error updating user info: \(error)")
            return nil
        }
    }
}
