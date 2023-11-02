//
//  Model.swift
//  Celery
//
//  Created by Skylar Clemens on 10/19/23.
//

import Foundation

@MainActor
class Model: ObservableObject {
    @Published var debts: [Debt]?
    @Published var groups: [GroupInfo]?
    @Published var recentUsers: [UserInfo]?
    
    func fetchInitialDebts() async throws {
        let userDebts = try await SupabaseManager.shared.getDebtsWithExpense(count: 10)
        self.debts = userDebts
    }
    
    func fetchDebts() async throws {
        let usersDebts = try await SupabaseManager.shared.getDebtsWithExpense()
        self.debts = usersDebts
    }
    
    func addDebts(_ debtsToAdd: [DebtModel]) async throws {
        let createdDebts = try await SupabaseManager.shared.addNewDebts(debts: debtsToAdd)
        if let createdDebts,
           debts != nil {
            self.debts! = createdDebts + self.debts!
        }
    }
    
    func removeDebts(expenseId: UUID) async throws {
        try await SupabaseManager.shared.deleteExpense(expenseId: expenseId)
        if let debts = self.debts {
            self.debts = debts.filter { $0.expense?.id != expenseId }
        }
    }
    
    func fetchGroups() async throws {
        let usersGroups = try await SupabaseManager.shared.getUsersGroupsWithMembers()
        self.groups = usersGroups
    }
    
    func addGroup(_ groupToAdd: GroupModel, members: [UserInfo]) async throws -> GroupInfo? {
        let createdGroup = try await SupabaseManager.shared.addNewGroup(group: groupToAdd)
        if let createdGroup {
            for member in members {
                try await SupabaseManager.shared.addNewUserGroup(userId: member.id, groupId: createdGroup.id)
            }
            if groups != nil {
                self.groups!.append(createdGroup)
            }
        }
        return createdGroup
    }
    
    func deleteGroup(_ groupId: UUID) async throws {
        try await SupabaseManager.shared.deleteGroup(groupId: groupId)
        removeGroup(groupId)
    }
    
    func removeGroup(_ groupId: UUID) {
        if let index = groups?.firstIndex(where: { $0.id == groupId }) {
            self.groups?.remove(at: index)
        }
    }
    
    func updateGroup(_ updatedGroup: GroupModel) async throws {
        do {
            let newGroup = try await SupabaseManager.shared.updateGroup(group: updatedGroup)
            if let newGroup,
               let index = self.groups?.firstIndex(where: { $0.id == newGroup.id }) {
                self.groups?[index] = newGroup
            }
        } catch {
            print("Error updating group")
        }
    }
    
    func reset() {
        self.debts = nil
        self.groups = nil
        self.recentUsers = nil
    }
}
