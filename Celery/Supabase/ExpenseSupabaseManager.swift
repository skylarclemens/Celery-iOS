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
        do {
            let debts: [Debt] = try await self.client.database.from("debt")
                .insert(values: debts, returning: .representation)
                .select(columns: """
                *,
                creditor: creditor_id!inner(*),
                debtor: debtor_id!inner(*),
                expense: expense_id!inner(*)
                """)
                .execute()
                .value
            return debts
        } catch {
            print("Error creating new debts: \(error)")
            return nil
        }
    }
    
    func getDebtsByExpense(expenseId: UUID?) async throws -> [Debt]? {
        do {
            guard let expenseId else { return nil }
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
        do {
            let currentUserId = try await self.client.auth.session.user.id
            
            let debts: [Debt] = try await self.client.database.from("debt")
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
                .value
            return debts
        } catch {
            print("Error fetching debts: \(error)")
            return nil
        }
    }
    
    func getDebtsWithExpense(count: Int) async throws -> [Debt]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            
            let debts: [Debt] = try await self.client.database.from("debt")
                .select(columns: """
                *,
                creditor: creditor_id!inner(*),
                debtor: debtor_id!inner(*),
                expense: expense_id!inner(*)
                """)
                .eq(column: "paid", value: false)
                .or(filters: "debtor_id.eq.\(currentUserId.uuidString),creditor_id.eq.\(currentUserId.uuidString)")
                .order(column: "created_at", ascending: false)
                .limit(count: count)
                .execute()
                .value
            return debts
        } catch {
            print("Error fetching debts: \(error)")
            return nil
        }
    }
    
    func getDebtsByExpenseIds(expenseIds: [UUID]) async throws -> [Debt]? {
        do {
            let debts: [Debt] = try await self.client.database.from("debt")
                .select(columns: """
                *,
                creditor: creditor_id!inner(*),
                debtor: debtor_id!inner(*),
                expense: expense_id!inner(*)
                """)
                .in(column: "expense_id", value: expenseIds)
                .execute()
                .value
            return debts
        } catch {
            print("Error fetching debts by expense IDs: \(error)")
            return nil
        }
    }
    
    // Get related debts between current user and another user
    func getSharedDebtsWithExpenses(friendId: UUID) async throws -> [Debt]? {
        do {
            let currentUserId = try await self.client.auth.session.user.id
            let debts: [Debt] = try await self.client.database.from("debt")
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
            return debts
        } catch {
            print("Error fetching debts: \(error)")
            return nil
        }
    }
    
    func updateDebts(_ debts: [DebtModel]) async throws {
        do {
            try await self.client.database.from("debt")
                .upsert(values: debts)
                .execute()
        } catch {
            print("Error updating expenses: \(error)")
        }
    }
    
    // MARK: Expense methods
    
    // Add new expenses to database
    func addNewExpense(expense: Expense) async throws -> Expense? {
        do {
            let expense: [Expense] = try await self.client.database.from("expense")
                .insert(values: expense, returning: .representation)
                .select()
                .execute()
                .value
            return expense.first
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
    
    func updateExpenses(_ expenses: [Expense]) async throws {
        do {
            try await self.client.database.from("expense")
                .upsert(values: expenses)
                .execute()
        } catch {
            print("Error updating expenses: \(error)")
        }
    }
}
