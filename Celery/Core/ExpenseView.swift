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
    
    init(expense: Expense) {
        self.expense = expense
    }
    
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
                                .fill(Color(hex: Category.categoryList[expense.category ?? "Category"]?.colorUInt ?? 0x6A9B5D)
                                    .shadow(.inner(color: .black.opacity(0.1), radius: 10, y: -2))
                                )
                            
                            Image(expense.category ?? "Category")
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
                                Text(expense.name ?? "Unknown name")
                                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                                Text(expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary.opacity(0.75))
                            }
                            .padding(.top, 24)
                            Button {
                                
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
                            .cornerRadius(16)
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
                    .offset(y: 30)
                }.zIndex(2)
                List {
                    Section {
                        Text(expense.payerID ?? "Payer")
                    } header: {
                        Text("Paid by")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.9))
                            .textCase(nil)
                            .padding(.top, 16)
                    }
                    Section {
                        Text("Split")
                    } header: {
                        Text("Split with")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.9))
                            .textCase(nil)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        ExpenseView(expense: Expense(id: UUID().uuidString, name: "Test", description: nil, amount: 10.00, payerID: "Test-UUID", groupID: nil, category: "Entertainment", date: Date(), createdAt: Date()))
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
