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
    
    @State private var currentUser: UserInfo? = nil
    
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
                                Text("You").tag("You")
                                ForEach(newExpense.splitWith.dropFirst()) { user in
                                    Text(user.name ?? "Unknown user").tag(user.id.uuidString)
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
                            /*HStack {
                                Button {
                                    newExpense.selectedSplit = .equal
                                } label: {
                                    Image(systemName: "equal")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.primary)
                                        .frame(maxWidth: 40, maxHeight: 30)
                                        .background(
                                            Capsule()
                                                .strokeBorder(newExpense.selectedSplit == .equal ? .blue : Color.secondary.opacity(0.5), lineWidth: newExpense.selectedSplit == .equal ? 2 : 1, antialiased: true)
                                                .background(
                                                    Capsule()
                                                        .fill(Color(uiColor: UIColor.tertiarySystemGroupedBackground))
                                                )
                                        )
                                }
                                Spacer()
                                Button {
                                    newExpense.selectedSplit = .exact
                                } label: {
                                    Image(systemName: "dollarsign")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.primary)
                                        .padding(12)
                                        .frame(maxWidth: 40, maxHeight: 30)
                                        .background(
                                            Capsule()
                                                .strokeBorder(newExpense.selectedSplit == .exact ? .blue : Color.secondary.opacity(0.5), lineWidth: newExpense.selectedSplit == .exact ? 2 : 1, antialiased: true)
                                                .background(
                                                    Capsule()
                                                        .fill(Color(uiColor: UIColor.tertiarySystemGroupedBackground))
                                                )
                                        )
                                }
                            }
                            .padding(.bottom, 8)*/
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
                            //dismiss()
                            print("Name: \(newExpense.name)")
                            print("Paid by: \(newExpense.paidBy == "You" ? currentUser?.id.uuidString : newExpense.paidBy)")
                            print("Amount: \(newExpense.amount)")
                            
                            print("======== User Split With =========")
                            print(newExpense.splitWith)
                            print("======== User Amounts =========")
                            print(newExpense.userAmounts)
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
            print(newValue)
            userDebts = newValue.map { user in
                Binding(
                    get: { newExpense.userAmounts[user.id] ?? 0.0 },
                    set: { newValue in
                        newExpense.userAmounts[user.id] = newValue
                    }
                )
            }
            print(newExpense.userAmounts)
        }
        .onAppear {
            if let currentUserInfo = authViewModel.currentUserInfo {
                self.currentUser = currentUserInfo
            }
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
