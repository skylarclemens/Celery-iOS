//
//  DetailsView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/16/23.
//

import SwiftUI

struct ExpenseView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    let expense: Expense
    @State var debts: [Debt]? = nil
    @State var activities: [Activity]?
    let currencyFormatter: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    @State private var showDeleteAlert = false
    //@State private var openPayView = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color(uiColor:UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: Category.categoryList.first(where: {
                        $0.name == expense.category?.capitalized
                    })?.colorUInt ?? 0x6A9B5D))
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 0)
                Image(expense.category?.capitalized ?? "General")
                    .resizable()
                    .frame(width: 135, height: 135)
                    .offset(x: -5, y: 20)
                //.rotationEffect(.degrees(-15))
                    .opacity(0.25)
                HStack {
                    VStack(alignment: .leading) {
                        Text(expense.description ?? "Unknown name")
                            .font(.system(size: 36, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                        Text(expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                    /*Button {
                        openPayView = true
                    } label: {
                        Text("Pay")
                            .fontWeight(.medium)
                            .foregroundStyle(Color(hex: Category.categoryList.first(where: {
                                $0.name == expense.category?.capitalized
                            })?.colorUInt ?? 0x000000))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(.white)
                    )*/
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 200)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .ignoresSafeArea()
            .zIndex(1)
            
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
                Section {
                    if let activities {
                        ForEach(activities) { activity in
                            ActivityView(activity: activity)
                        }
                    }
                } header: {
                    Text("Activity")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.9))
                        .textCase(nil)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
            }
            .offset(y: 100)
        }
        /*.sheet(isPresented: $openPayView) {
            PayView(amount: expense.amount ?? 0.0)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }*/
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .alert("Delete \(expense.description ?? "expense")", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    await deleteExpense()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to permanently delete this expense?")
        }
        .task {
            self.debts = try? await SupabaseManager.shared.getDebtsByExpense(expenseId: expense.id)
            self.activities = try? await SupabaseManager.shared.getRelatedActivities(for: expense.id)
        }
    }
    
    func deleteExpense() async {
        if let expenseId = expense.id {
            try? await SupabaseManager.shared.deleteExpense(expenseId: expenseId)
        }
    }
}

#Preview {
    NavigationStack{
        ExpenseView(expense: Expense.example)
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
