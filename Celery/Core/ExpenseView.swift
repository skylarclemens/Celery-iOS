//
//  DetailsView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/16/23.
//

import SwiftUI

struct ExpenseView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let expense: Expense
    @State var debts: [Debt]? = nil
    let currencyFormatter: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(uiColor:UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    if colorScheme != .dark {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.42, green: 0.61, blue: 0.36), Color(red: 0.36, green: 0.53, blue: 0.32)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .shadow(.inner(color: .black.opacity(0.25), radius: 0, x: 0, y: -3))
                            )
                            .roundedCorners(24, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                            .frame(maxHeight: 140)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(maxHeight: 140)
                    }
                    ZStack(alignment: .top) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: Category.categoryList[expense.category?.capitalized ?? "General"]?.colorUInt ?? 0x6A9B5D)
                                    .shadow(.inner(color: .black.opacity(0.1), radius: 10, y: -2))
                                )
                            Image(expense.category?.capitalized ?? "General")
                                .resizable()
                                .frame(maxWidth: 40, maxHeight: 40)
                            Circle()
                                .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 4)
                        }
                        .frame(width: 65, height: 65)
                        .offset(y: -32.5)
                        .zIndex(1)
                        VStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text(expense.description ?? "Unknown name")
                                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                                Text(expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary.opacity(0.75))
                            }
                            .padding(.top, 24)
                            /*Button {
                                
                            } label: {
                                Text("Pay")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 32)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.layoutGreen, lineWidth: 1)
                                    )
                            }
                            .background(Color.primaryAction)
                            .cornerRadius(16)*/
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(uiColor: UIColor.secondarySystemGroupedBackground))
                                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 4)
                                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 0)
                        )
                    }
                    .padding()
                    .offset(y: 20)
                }.zIndex(2)
                List {
                    Section {
                        if let firstDebt = debts?.first,
                           let creditor = firstDebt.creditor {
                            HStack {
                                HStack {
                                    UserPhotoView(size: 50, imagePath: creditor.avatar_url)
                                    Text(creditor.name ?? "Unknown user")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                Spacer()
                                Text(expense.amount ?? 0.00, format: currencyFormatter)
                                    .foregroundStyle(Color.layoutGreen)
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                        }
                    } header: {
                        Text("Paid by")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.9))
                            .textCase(nil)
                            .padding(.top, 16)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    Section {
                        if let debts {
                            ForEach(debts) { debt in
                                if let debtor = debt.debtor {
                                    HStack {
                                        HStack {
                                            UserPhotoView(size: 50, imagePath: debtor.avatar_url)
                                            Text(debtor.name ?? "Unknown user")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        Spacer()
                                        Text(debt.amount ?? 0.00, format: currencyFormatter)
                                            .foregroundStyle(Color.layoutRed)
                                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Split with")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.9))
                            .textCase(nil)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                }
            }
        }
        .task {
            self.debts = try? await SupabaseManager.shared.getDebtsByExpense(expenseId: expense.id)
        }
    }
}

#Preview {
    NavigationStack{
        ExpenseView(expense: Expense(id: UUID(), paid: false, description: "Test", amount: 10.00, payer_id: "Test-UUID", group_id: nil, category: "ENTERTAINMENT", date: Date(), created_at: Date()))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        Text("Back")
                    }
                }
            }
            
    }
}
