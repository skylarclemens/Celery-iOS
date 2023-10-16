//
//  GroupsSupabaseManager.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import Foundation
import PostgREST

extension SupabaseManager {
    func getGroup(groupId: UUID) async throws -> GroupInfo? {
        do {
            let group: [GroupInfo] = try await client.database.from("group")
                .select()
                .eq(column: "id", value: groupId)
                .limit(count: 1)
                .execute()
                .value
            return group.first
        } catch {
            print(error)
            return nil
        }
    }
    
    func getUsersGroups() async throws -> [GroupInfo]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let groups: [GroupInfo] = try await client.database.from("user_group")
                .select(columns: "...group_id(*)")
                .eq(column: "user_id", value: currentUserId)
                .execute()
                .value
            //print(String(data: groups.underlyingResponse.data, encoding: .utf8))
            return groups
        } catch {
            print(error)
            return nil
        }
    }
    
    func getGroupMembers(groupId: UUID) async throws -> [UserInfo]? {
        do {
            let users: [UserInfo] = try await client.database.from("user_group")
                .select(columns: "...user_id(*)")
                .eq(column: "group_id", value: groupId)
                .execute()
                .value
            return users
        } catch {
            print(error)
            return nil
        }
    }
    
    func getGroupDebtsWithExpenses(groupId: UUID) async throws -> [Debt]? {
        let decoder = JSONDecoder()
        // Decode ISO8601 dates and yyyy-MM-dd formatted dates
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            let dateFormatter = DateFormatter()
            if dateString.wholeMatch(of: /\d{4}-\d{2}-\d{2}/) != nil {
                dateFormatter.dateFormat = "yyyy-MM-dd"
            } else {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                dateFormatter.calendar = Calendar(identifier: .iso8601)
            }
            guard let date = dateFormatter.date(from: dateString) else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date") }
            return date
        }
        
        do {
            let response = try await self.client.database.from("debt")
                .select(columns: """
                *,
                creditor: creditor_id!inner(*),
                debtor: debtor_id!inner(*),
                expense: expense_id!inner(*)
                """)
                .eq(column: "paid", value: false)
                .eq(column: "group_id", value: groupId)
                .order(column: "created_at", ascending: false)
                .execute()
            let data = try decoder.decode([Debt].self, from: response.underlyingResponse.data)
            return data
        } catch {
            print("Error fetching debts: \(error)")
            return nil
        }
    }
    
    func addNewGroup(group: GroupInfo) async throws {
        do {
            try await self.client.database.from("group")
                .insert(values: group, returning: .representation)
                .select()
                .execute()
        } catch {
            print("Error creating new group: \(error)")
        }
    }
    
    struct UserGroup: Encodable {
        let user_id: UUID?
        let group_id: UUID?
    }
    
    func addNewUserGroup(userId: UUID, groupId: UUID) async throws {
        let newUserGroup = UserGroup(user_id: userId, group_id: groupId)
        
        do {
            try await self.client.database.from("user_group")
                .insert(values: newUserGroup)
                .execute()
        } catch {
            print("Error adding to user_group: \(error)")
        }
    }
    
    func getGroupsByQuery(value: String) async throws -> [GroupInfo]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let queriedGroups: [GroupInfo] = try await self.client.database.from("user_group")
                .select(columns: "...group!inner(*)")
                .eq(column: "user_id", value: currentUserId)
                .ilike(column: "group.group_name", value: "%\(value)%")
                .execute()
                .value
            return queriedGroups
        } catch {
            print("Error fetching groups: \(error)")
            return nil
        }
    }
}
