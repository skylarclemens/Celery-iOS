//
//  ExpenseManager.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Expense: Identifiable, Codable {
    let id: String
    let name: String?
    let description: String?
    let amount: Double?
    let payerID: String?
    let groupID: String?
    let category: String?
    let date: Date?
    let createdAt: Date?
}

final class ExpenseManager {
    static let shared = ExpenseManager()
    private init() {}
    
    private let collection = Firestore.firestore().collection("expenses")
    private func expenseDocument(_ expenseId: String) -> DocumentReference { collection.document(expenseId) }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewExpense(expense: Expense) async throws {
        try expenseDocument(expense.id).setData(from: expense, encoder: encoder)
    }
    
    func getExpense(expenseId: String) async throws -> Expense {
        try await expenseDocument(expenseId).getDocument(as: Expense.self, decoder: decoder)
    }
    
    func getUsersExpenses(user: UserInfo) async throws -> [Expense] {
        try await collection.whereField("payer_id", isEqualTo: user.id).getDocuments(as: Expense.self)
    }
}

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T:Decodable {
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
    }
}
