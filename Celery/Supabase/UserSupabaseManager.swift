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
                user: user_id(*),
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
                user: user_id(*),
                friend: friend_id(*)
                """)
                .eq(column: "user_id", value: currentUserId)
                .eq(column: "friend_id", value: friendId)
                .execute()
                .value
            return friend.first
        } catch {
            print("Error fetching friend: \(error)")
            return nil
        }
    }
    
    func getFriendRequest(friendId: UUID) async throws -> UserFriend? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let friend: [UserFriend] = try await self.client.database.from("user_friend")
                .select(columns: """
                *,
                user: user_id(*),
                friend: friend_id(*)
                """)
                .eq(column: "user_id", value: friendId)
                .eq(column: "friend_id", value: currentUserId)
                .eq(column: "status", value: 0)
                .execute()
                .value
            return friend.first
        } catch {
            print("Error fetching friend: \(error)")
            return nil
        }
    }
    
    func getAllFriendRequests() async throws -> [UserFriend]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let requests: [UserFriend] = try await self.client.database.from("user_friend")
                .select(columns: """
                *,
                user: user_id(*),
                friend: friend_id(*)
                """)
                .eq(column: "friend_id", value: currentUserId)
                .eq(column: "status", value: 0)
                .execute()
                .value
            return requests
        } catch {
            print("Error fetching all friend requests: \(error)")
            return nil
        }
    }
    
    func addFriendRequest(friendId: UUID) async throws -> UserFriend? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let newRequest = UserFriendModel(user_id: currentUserId, friend_id: friendId, status: 0, status_change: nil)
            let friend: [UserFriend] = try await self.client.database.from("user_friend")
                .insert(values: newRequest, returning: .representation)
                .select()
                .execute()
                .value
            return friend.first
        } catch {
            print("Error adding friend request: \(error)")
            return nil
        }
    }
    
    func updateFriendStatus(user1: UUID, user2: UUID, status: Int) async throws {
        do {
            let updatedStatus = UserFriendModel(user_id: user1, friend_id: user2, status: status, status_change: Date())
            try await self.client.database.from("user_friend")
                .update(values: updatedStatus)
                .eq(column: "user_id", value: user1)
                .eq(column: "friend_id", value: user2)
                .execute()
        } catch {
            print("Error updating friend status: \(error)")
        }
    }
    
    func addNewFriend(request: UserFriend) async throws -> UserFriend? {
        do {
            let newRequest = UserFriendModel(user_id: request.friend?.id, friend_id: request.user?.id, status: 1, status_change: Date())
            let friend: [UserFriend] = try await self.client.database.from("user_friend")
                .upsert(values: newRequest, returning: .representation)
                .select(columns: """
                *,
                user: user_id(*),
                friend: friend_id(*)
                """)
                .execute()
                .value
            return friend.first
        } catch {
            print("Error adding friend: \(error)")
            return nil
        }
    }
    
    func removeFriendship(user1: UUID, user2: UUID) async throws {
        do {
            try await self.client.database.from("user_friend")
                .delete()
                .eq(column: "user_id", value: user1)
                .eq(column: "friend_id", value: user2)
                .execute()
        } catch {
            print("Error removing friendship: \(error)")
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
