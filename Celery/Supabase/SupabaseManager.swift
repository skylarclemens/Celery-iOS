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
    
    // Get user's current debts with associated expense
    func getDebtsWithExpense() async throws -> [Debt]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            
            let transactionsList: [Debt] = try await self.client.database.from("debt")
                .select(columns: """
                *,
                expense: expense_id!inner(*)
                """)
                .eq(column: "paid", value: false)
                .or(filters: "debtor_id.eq.\(currentUserId.uuidString),creditor_id.eq.\(currentUserId.uuidString)")
                .order(column: "created_at", ascending: false)
                .execute()
                .value
            return transactionsList
        } catch {
            print("Error fetching debts: \(error)")
            return nil
        }
    }
    
    // Get related debts between current user and another user
    func getSharedDebtsWithExpenses(friendId: UUID) async throws -> [Debt]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let transactionsList: [Debt] = try await self.client.database.from("debt")
                .select(columns: """
                *,
                creditor: creditor_id!inner(*),
                debtor: debtor_id!inner(*),
                expense: expense_id!inner(*)
                """)
                .eq(column: "paid", value: false)
                .or(filters: "and(creditor_id.eq.\(currentUserId),debtor_id.eq.\(friendId)),and(creditor_id.eq.\(friendId),debtor_id.eq.\(currentUserId))")
                .order(column: "created_at", ascending: false)
                .execute()
                .value
            return transactionsList
        } catch {
            print("Error fetching debts: \(error)")
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
                .or(filters: "email.ilike.%\(value)%,name.ilike.%\(value)%,username.ilike.%\(value)")
                .execute()
                .value
            return queriedUsers
        } catch {
            print("Error fetching users: \(error)")
            return nil
        }
    }
    
    // Add new expenses to database
    func addNewExpense(expense: Expense) async throws -> Expense? {
        do {
            let newExpense: [Expense] = try await self.client.database.from("expense")
                .insert(values: expense, returning: .representation)
                .select()
                .execute()
                .value
            return newExpense.first
        } catch {
            print("Error creating new expense: \(error)")
            return nil
        }
    }
    
    // Add new debts to database
    func addNewDebts(debts: [DebtModel]) async throws -> [DebtModel]? {
        do {
            let newDebts: [DebtModel] = try await self.client.database.from("debt")
                .insert(values: debts, returning: .representation)
                .select()
                .execute()
                .value
            return newDebts
        } catch {
            print("Error creating new debts: \(error)")
            return nil
        }
    }
    
    // Fetch activity
    func getActivity(id: Int) async throws -> Activity? {
        do {
            let fetchedActivity: [Activity] = try await self.client.database.from("activity")
                .select()
                .eq(column: "id", value: id)
                .execute()
                .value
            return fetchedActivity.first
        } catch {
            print("Error fetching activity: \(error)")
            return nil
        }
    }
    
    // Add new activity to database
    func addNewActivity(activity: Activity) async throws {
        do {
            try await self.client.database.from("activity")
                .insert(values: activity)
                .execute()
        } catch {
            print("Error creating new activity: \(error)")
        }
    }
    
    func getRelatedActivities(for referenceId: UUID?) async throws -> [Activity]? {
        guard let referenceId else { return nil }
        do {
            let fetchedActivities: [Activity] = try await self.client.database.from("activity")
                .select()
                .eq(column: "reference_id", value: referenceId)
                .execute()
                .value
            return fetchedActivities
        } catch {
            print("Error fetching related activities: \(error)")
            return nil
        }
    }
}
