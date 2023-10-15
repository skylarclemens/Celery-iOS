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
    @Binding var isOpen: Bool
    
    @State private var creatingExpense: Bool = false
    
    var invalidForm: Bool {
        newExpense.splitWith.count <= 1 || newExpense.paidBy == nil
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            ScrollView {
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
                }
                .padding(.horizontal)
            }
            VStack {
                Spacer()
                Button {
                    Task {
                        do {
                            try await onSubmit()
                            isOpen = false
                        } catch {
                            print("Error submitting")
                        }
                    }
                } label: {
                    Group {
                        if !creatingExpense {
                            Text("Send")
                        } else {
                            ProgressView()
                                .tint(.white)
                                .controlSize(.regular)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .font(.headline)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(invalidForm ? Color.secondary.opacity(0.25) : Color.layoutGreen, lineWidth: 1))
                .padding(.top, 8)
                .padding(.horizontal)
                .tint(.primaryAction)
                .disabled(invalidForm)
            }
            .zIndex(1)
            .ignoresSafeArea(.keyboard, edges: .bottom)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isOpen = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(uiColor: UIColor.secondaryLabel), Color(uiColor: UIColor.tertiarySystemFill))
                }
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
    }
    
    func onSubmit() async throws {
        let newCategory = self.newExpense.category == "Category" ? "General" : self.newExpense.category
        var createdExpense: Expense?
        var createdDebts: [DebtModel]?
        do {
            creatingExpense = true
            let createExpense: Expense = Expense(description: self.newExpense.name, amount: self.newExpense.amount, payer_id: self.newExpense.paidBy?.id.uuidString, category: newCategory, date: self.newExpense.date)
            createdExpense = try await SupabaseManager.shared.addNewExpense(expense: createExpense)
        } catch {
            print("Error creating expense: \(error)")
        }
        
        do {
            if let createdExpense {
                let createDebts: [DebtModel] = self.newExpense.splitWith.compactMap { user in
                    if self.newExpense.paidBy?.id == user.id { return nil }
                    return DebtModel(amount: self.newExpense.userAmounts[user.id], creditor_id: self.newExpense.paidBy?.id, debtor_id: user.id, expense_id: createdExpense.id)
                }
                createdDebts = try await SupabaseManager.shared.addNewDebts(debts: createDebts)
            }
        } catch {
            print("Error creating debts: \(error)")
        }
        
        do {
            if let _ =
                createdDebts {
                let createActivity = Activity(user_id: self.currentUser?.id, reference_id: createdExpense?.id, type: .expense, action: .create)
                try await SupabaseManager.shared.addNewActivity(activity: createActivity)
            }
        } catch {
            print("Error creating activity: \(error)")
        }
        creatingExpense = false
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
        CreateExpenseSplitView(newExpense: NewExpense(), isOpen: .constant(true))
            .environmentObject(AuthenticationViewModel())
    }
}
