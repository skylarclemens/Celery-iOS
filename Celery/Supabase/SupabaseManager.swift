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
    
    func getDebtsByExpense(expenseId: UUID?) async throws -> [Debt]? {
        guard let expenseId else { return nil }
        do {
            let debts: [Debt] = try await self.client.database.from("debt")
                .select(columns: """
                id,
                amount,
                creditor: creditor_id!inner(*),
                debtor: debtor_id!inner(*),
                paid,
                group_id,
                created_at
                """)
                .eq(column: "expense_id", value: expenseId)
                .eq(column: "paid", value: false)
                //.or(filters: "debtor_id.eq.\(currentUserId.uuidString),creditor_id.eq.\(currentUserId.uuidString)")
                .order(column: "created_at", ascending: false)
                .execute()
                .value
            return debts
        } catch {
            print("Error fetching debts by expense: \(error)")
            return nil
        }
    }
    
    // Get user's current debts with associated expense
    func getDebtsWithExpense() async throws -> [Debt]? {
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
            let currentUserId = try await self.client.auth.session.user.id
            //print(currentUserId)
            /*let transactionsList: [Debt] = try await self.client.database.from("debt")
                .select(columns: """
                *,
                expense: expense_id!inner(*)
                """)
                .eq(column: "paid", value: false)
                .or(filters: "debtor_id.eq.\(currentUserId.uuidString),creditor_id.eq.\(currentUserId.uuidString)")
                .order(column: "created_at", ascending: false)
                .execute()
                .value
            return transactionsList*/
            let response = try await self.client.database.from("debt")
                .select(columns: """
                *,
                creditor: creditor_id!inner(*),
                debtor: debtor_id!inner(*),
                expense: expense_id!inner(*)
                """)
                .eq(column: "paid", value: false)
                .or(filters: "debtor_id.eq.\(currentUserId.uuidString),creditor_id.eq.\(currentUserId.uuidString)")
                .order(column: "created_at", ascending: false)
                .execute()
            let data = try decoder.decode([Debt].self, from: response.underlyingResponse.data)
            //print(String(data: response.underlyingResponse.data, encoding: .utf8))
            //print("=========\n \(data)")
            return data
        } catch {
            print("Error fetching debts: \(error)")
            return nil
        }
    }
}
