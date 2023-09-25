//
//  CreateExpenseSplitView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/25/23.
//

import SwiftUI

struct CreateExpenseSplitView: View {
    @ObservedObject var newExpense: NewExpense
    @State private var openUserSelection: Bool = false
    private let currencyFormat: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    var body: some View {
        VStack {
            AtomView() {
                Text(newExpense.amount, format: currencyFormat)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white
                        .shadow(.drop(color: .black.opacity(0.15), radius: 0, y: 2)))
            }
            Spacer()
            Section {
                VStack {
                    
                    HStack {
                        if !newExpense.splitWith.isEmpty {
                            ForEach(newExpense.splitWith) { user in
                                VStack {
                                    UserPhotoView(size: 40, imagePath: user.avatar_url)
                                    Text(user.name ?? "Unknown name")
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
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.tertiary.opacity(0.75), lineWidth: 1, antialiased: true)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                )
            } header: {
                HStack {
                    Text("Split with")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .padding(.leading, 8)
                    Spacer()
                    Button {
                        openUserSelection = true
                    } label: {
                        if newExpense.splitWith.isEmpty {
                            Image(systemName: "plus")
                        } else {
                            Text("Edit")
                                .font(.system(size: 14))
                        }
                    }
                    .foregroundStyle(Color.secondary)
                    .buttonStyle(.borderedProminent)
                    .clipShape(Capsule())
                    .tint(Color(uiColor: UIColor.systemGroupedBackground))
                }
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $openUserSelection) {
            SelectUsersView(selectedUsers: $newExpense.splitWith)
        }
        .navigationTitle("Split details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            CreateExpenseSplitView(newExpense: NewExpense())
        }
    }
}
