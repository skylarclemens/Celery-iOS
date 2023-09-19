//
//  TransactionsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var userExpenses: [Expense]?
    
    /*func getUserExpenses(userId: String) async throws {
        self.userExpenses = try? await ExpenseManager.shared.getUsersExpenses(userId: userId)
    }*/
}

struct TransactionsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var viewModel = TransactionsViewModel()
    @State var transactionsList: [DebtModel] = []
    @State var userId: String = ""
    
    var body: some View {
        List {
            Section {
                if !transactionsList.isEmpty {
                    ForEach(transactionsList) { debt in
                        let userOwed = debt.creditor_id?.uppercased() == userId.uppercased()
                        NavigationLink {
                            //ExpenseView(expense: expense)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: Category.categoryList[debt.expense?.category?.capitalized ?? "Category"]?.colorUInt ?? 0x6A9B5D)
                                            .shadow(.inner(color: .black.opacity(0.1), radius: 10, y: -2))
                                            .shadow(.drop(color: .black.opacity(0.2), radius: 2, y: 1))
                                        )
                                        
                                    Image(debt.expense?.category?.capitalized ?? "Category")
                                        .resizable()
                                        .frame(maxWidth: 20, maxHeight: 20)
                                    Circle()
                                        .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 2)
                                }
                                .frame(width: 40, height: 40)
                                VStack(alignment: .leading) {
                                    Text(debt.expense?.description ?? "Unknown name")
                                        .font(.system(size: 16, weight: .semibold))
                                    /*Text(expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)*/
                                }
                                Spacer()
                                HStack(spacing: 0) {
                                    Text(userOwed ? "+" : "-")
                                    Text(debt.amount ?? 0, format: .currency(code: "USD"))
                                }
                                .foregroundStyle(!userOwed ? Color.layoutRed : Color.layoutGreen)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    }
                } else {
                    Text("No expenses")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Transactions")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary.opacity(0.9))
                    .textCase(nil)
                    .padding(.bottom, 8)
            }
        }
        .onAppear {
            Task {
                try await getDebtsExpenses()
            }
        }
    }
    
    func getDebtsExpenses() async throws {
        do {
            let currentUserId = try await SupabaseManager.shared.client.auth.session.user.id
            self.userId = currentUserId.uuidString
            //print(currentUserId)
            self.transactionsList = try await SupabaseManager.shared.client.database.from("debt")
                .select(columns: """
                *,
                expense: expense_id!inner(id, paid, description, amount, category)
                """)
                .eq(column: "paid", value: false)
                .or(filters: "debtor_id.eq.\(currentUserId.uuidString),creditor_id.eq.\(currentUserId.uuidString)")
                .order(column: "created_at", ascending: false)
                .execute()
                .value
            //print(transactionsList)
            /*let response = try await SupabaseManager.shared.client.database.from("user_friend")
                .select(columns: "friend_id!inner(*)")
                .eq(column: "user_id", value: currentUserId)
                .eq(column: "status", value: 1)
                .execute()
            print(response.status)
            print(response.underlyingResponse.response)
            print(response.underlyingResponse.data)
            print(String(data: response.underlyingResponse.data, encoding: .utf8))*/
        } catch {
            print("Error fetching debts: \(error)")
        }
    }
    
    /*getDebtsWithExpenses: builder.query({
     queryFn: async (userId) => {
       const { data, error } = await supabase
         .from('debt')
         .select('*, expense: expense_id(*)')
         .or(`debtor_id.eq.${userId},creditor_id.eq.${userId}`)
         .order('created_at', { ascending: false });
       return { data, error };
     },
     providesTags: (result = [], error, arg) => [
       { type: 'Debt', id: 'LIST' },
       ...result.map(({ id }) => ({ type: 'Debt', id: id }))
     ]
   }),
     */
}

#Preview {
    NavigationStack {
        TransactionsView()
            .environmentObject(AuthenticationViewModel())
    }
}
