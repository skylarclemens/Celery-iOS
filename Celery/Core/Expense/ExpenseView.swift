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
    @EnvironmentObject var model: Model
    @EnvironmentObject var toastManager: ToastManager
    let expense: Expense
    @State var debts: [Debt]? = nil
    @State var activities: [Activity]?
    let currencyFormatter: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    @State private var showDeleteAlert = false
    //@State private var openPayView = false
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                let offset = geometry.frame(in: .global).minY
                ExpenseHeader(expense: expense)
                    .offset(y: offset > 0 ? -offset : 0)
            }
            .frame(height: 220)
            VStack(spacing: 16) {
                VStackListSection(header: "Paid by") {
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
                }
                VStackListSection(header: "Split with") {
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
                }
                VStackListSection(header: "Activity") {
                    if let activities {
                        ForEach(activities) { activity in
                            ActivityView(activity: activity)
                        }
                    }
                }
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .ignoresSafeArea(.container, edges: .top)
        .background(
            Rectangle()
                .fill(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()
        )
        /*.sheet(isPresented: $openPayView) {
            PayView(amount: expense.amount ?? 0.0)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }*/
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(.regularMaterial)
                            .frame(width: 30)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(.regularMaterial)
                            .frame(width: 30)
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(UIColor.secondaryLabel))
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .alert("Delete \(expense.description ?? "expense")", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    toastManager.successTitle = "\(expense.description ?? "Expense") has been deleted"
                    await deleteExpense()
                    toastManager.isSuccess = true
                    toastManager.showAlert = true
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
        try? await model.removeDebts(expenseId: expense.id)
    }
}

#Preview {
    NavigationStack{
        ExpenseView(expense: Expense.example)
            .environmentObject(AuthenticationViewModel())
            .environmentObject(Model())
            .environmentObject(ToastManager())
    }
}

struct ExpenseHeader: View {
    let expense: Expense
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .fill(Color(hex: Category.categoryList.first(where: {
                    $0.name == expense.category?.capitalized
                })?.colorUInt ?? 0x6A9B5D))
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                            stops: [
                            Gradient.Stop(color: .black.opacity(0.25), location: 0.00),
                            Gradient.Stop(color: .black.opacity(0), location: 1.00),
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                            )
                        )
                )
            Image(expense.category?.capitalized ?? "General")
                .resizable()
                .frame(width: 135, height: 135)
                .offset(x: -5, y: 20)
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
        .clipped()
    }
}

// Allow user to navigate back with swipe when navigation bar back button is hidden
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
