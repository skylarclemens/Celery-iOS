//
//  ExpenseSupabaseManager.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import Foundation

extension SupabaseManager {
    // MARK: Debt methods
    // Add new debts to database
    func addNewDebts(debts: [DebtModel]) async throws -> [Debt]? {
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
                .insert(values: debts, returning: .representation)
                .select(columns: """
                *,
                creditor: creditor_id!inner(*),
                debtor: debtor_id!inner(*),
                expense: expense_id!inner(*)
                """)
                .execute()
            let data = try decoder.decode([Debt].self, from: response.underlyingResponse.data)
            return data
        } catch {
            print("Error creating new debts: \(error)")
            return nil
        }
    }
    
    func getDebtsByExpense(expenseId: UUID?) async throws -> [Debt]? {
        guard let expenseId else { return nil }
        
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
            let data = try decoder.decode([Debt].self, from: response.underlyingResponse.data)
            return data
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
            return data
        } catch {
            print("Error fetching debts: \(error)")
            return nil
        }
    }
    
    // Get related debts between current user and another user
    func getSharedDebtsWithExpenses(friendId: UUID) async throws -> [Debt]? {
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
            let response = try await self.client.database.from("debt")
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
            let data = try decoder.decode([Debt].self, from: response.underlyingResponse.data)
            return data
        } catch {
            print("Error fetching debts: \(error)")
            return nil
        }
    }
    
    // MARK: Expense methods
    
    // Add new expenses to database
    func addNewExpense(expense: Expense) async throws -> Expense? {
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
            let response = try await self.client.database.from("expense")
                .insert(values: expense, returning: .representation)
                .select()
                .execute()
            let data = try decoder.decode([Expense].self, from: response.underlyingResponse.data)
            return data.first
        } catch {
            print("Error creating new expense: \(error)")
            return nil
        }
    }
    
    //Delete expense from database
    func deleteExpense(expenseId: UUID) async throws {
        do {
            try await self.client.database.from("expense")
                .delete()
                .eq(column: "id", value: expenseId)
                .execute()
        } catch {
            print("Error deleting expense: \(error)")
        }
    }
}
