//
//  CreateExpenseSplitView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/25/23.
//

import SwiftUI

enum SplitOption: CaseIterable, Identifiable, CustomStringConvertible {
    case equal, exact
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .equal: return "="
        case .exact: return "$"
        }
    }
}

struct CreateExpenseSplitView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var newExpense: NewExpense
    @State private var userDebts: [Binding<Double>] = []
    
    @State private var openUserSelection: Bool = false
    private let currencyFormat: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    var currentUser: UserInfo?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            VStack {
                AtomView() {
                    Text(newExpense.amount, format: currencyFormat)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white
                            .shadow(.drop(color: .black.opacity(0.15), radius: 0, y: 2)))
                }
                Spacer()
                VStack(alignment: .leading) {
                    Section {
                        HStack {
                            if !newExpense.splitWith.isEmpty {
                                ForEach(newExpense.splitWith) { user in
                                    VStack {
                                        UserPhotoView(size: 45, imagePath: user.avatar_url)
                                        Text(isCurrentUser(userId: user.id) ? "You" : user.name ?? "Unknown name")
                                            .font(.system(size: 12))
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                            .truncationMode(.tail)
                                    }
                                    .frame(maxWidth: 60)
                                }
                            } else {
                                Text("Add people to split the expense with")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 8)
                            }
                            Spacer()
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.tertiary.opacity(0.75), lineWidth: 1, antialiased: true)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                                )
                        )
                        .padding(.bottom, 16)
                    } header: {
                        HStack {
                            Text("Split with")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .padding(.leading, 8)
                            Spacer()
                            Button {
                                openUserSelection = true
                            } label: {
                                if newExpense.splitWith.count <= 1 {
                                    Image(systemName: "plus")
                                } else {
                                    Text("Edit")
                                        .font(.system(size: 14))
                                }
                            }
                            .foregroundStyle(Color.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .tint(Color(uiColor: UIColor.systemGroupedBackground))
                        }
                    }
                    Section {
                        HStack {
                            Picker("Paid by", selection: $newExpense.paidBy) {
                                Text("Select a user").tag(nil as UserInfo?)
                                ForEach(newExpense.splitWith) { user in
                                    Text(isCurrentUser(userId: user.id) ? "You" : user.name ?? "Unknown name").tag(user as UserInfo?)
                                }
                            }
                            .tint(.primary)
                            Spacer()
                        }
                        .padding(4)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.tertiary.opacity(0.75), lineWidth: 1, antialiased: true)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                                )
                        )
                        .padding(.bottom, 16)
                    } header: {
                        Text("Paid by")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .padding(.leading, 8)
                    }
                    Section {
                        VStack {
                            Picker("Split options", selection: $newExpense.selectedSplit) {
                                ForEach(SplitOption.allCases) { option in
                                    Text(String(describing: option))
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom, 8)
                            VStack {
                                if !newExpense.splitWith.isEmpty,
                                   !userDebts.isEmpty {
                                    ForEach(0..<newExpense.splitWith.count, id: \.self) { index in
                                        let user = newExpense.splitWith[index]
                                        UserSplitView(newExpense: newExpense, user: user, amount: userDebts[index], isCurrentUser: isCurrentUser(userId: user.id))
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.tertiary.opacity(0.75), lineWidth: 1, antialiased: true)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                                )
                        )
                    } header: {
                        Text("Split")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .padding(.leading, 8)
                    }
                    Spacer()
                    Section {
                        Button {
                            let newCategory = newExpense.category == "Category" ? "General" : newExpense.category
                            Task {
                                var createdExpense: Expense?
                                var createdDebts: [DebtModel]?
                                do {
                                    let createExpense: Expense = Expense(description: newExpense.name, amount: newExpense.amount, payer_id: newExpense.paidBy?.id.uuidString, category: newCategory, date: newExpense.date)
                                    createdExpense = try await SupabaseManager.shared.addNewExpense(expense: createExpense)
                                } catch {
                                    print("Error creating expense: \(error)")
                                }
                                
                                do {
                                    if let createdExpense {
                                        let createDebts: [DebtModel] = newExpense.splitWith.compactMap { user in
                                            if newExpense.paidBy?.id == user.id { return nil }
                                            return DebtModel(amount: newExpense.userAmounts[user.id], creditor_id: newExpense.paidBy?.id, debtor_id: user.id, expense_id: createdExpense.id)
                                        }
                                        createdDebts = try await SupabaseManager.shared.addNewDebts(debts: createDebts)
                                    }
                                } catch {
                                    print("Error creating debts: \(error)")
                                }
                                
                                do {
                                    if let _ =
                                        createdDebts {
                                        let createActivity = Activity(user_id: currentUser?.id, reference_id: createdExpense?.id, type: .expense, action: .create)
                                        try await SupabaseManager.shared.addNewActivity(activity: createActivity)
                                        dismiss()
                                    }
                                } catch {
                                    print("Error creating activity: \(error)")
                                }
                            }
                        } label: {
                            Text("Send")
                                .frame(maxWidth: .infinity)
                        }
                        .font(.headline)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.layoutGreen, lineWidth: 1))
                        .padding(.top, 8)
                        .tint(.primaryAction)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $openUserSelection) {
            SelectUsersView(selectedUsers: $newExpense.splitWith)
        }
        .onReceive(newExpense.$splitWith) { newValue in
            userDebts = newValue.map { user in
                Binding(
                    get: { newExpense.userAmounts[user.id] ?? 0.0 },
                    set: { newValue in
                        newExpense.userAmounts[user.id] = newValue
                    }
                )
            }
        }
        .onAppear {
            userDebts = newExpense.splitWith.map { user in
                Binding(
                    get: { newExpense.userAmounts[user.id] ?? 0.0 },
                    set: { newValue in
                        newExpense.userAmounts[user.id] = newValue
                    }
                )
            }
        }
        .navigationTitle("Split details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func onSubmit() async throws {
        
    }
    
    func isCurrentUser(userId: UUID) -> Bool {
        if let currentUser = self.currentUser {
            return currentUser.id == userId
        }
        return false
    }
}

#Preview {
    NavigationStack {
        CreateExpenseSplitView(newExpense: NewExpense())
            .environmentObject(AuthenticationViewModel())
    }
}
