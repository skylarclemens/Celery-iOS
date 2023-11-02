//
//  TransactionView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/15/23.
//

import SwiftUI

struct TransactionView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var debt: Debt

    var body: some View {
        NavigationLink {
            if let expense = debt.expense {
                ExpenseView(expense: expense)
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill((debt.expense?.categoryColor ?? Color("green"))
                            .shadow(.inner(color: .black.opacity(0.1), radius: 10, y: -2))
                            .shadow(.drop(color: .black.opacity(0.2), radius: 2, y: 1))
                        )
                    
                    Image(debt.expense?.category?.capitalized ?? "General")
                        .resizable()
                        .frame(maxWidth: 20, maxHeight: 20)
                    Circle()
                        .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: 2)
                }
                .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text(debt.expense?.description ?? "Unknown name")
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(debt.expense?.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                if let currentUser = authViewModel.currentUserInfo {
                    let userOwed = debt.creditor?.id == currentUser.id
                    HStack(spacing: 0) {
                        Text(userOwed ? "+" : "-")
                        Text(debt.amount ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    }
                    .foregroundStyle(!userOwed ? Color.layoutRed : Color.layoutGreen)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionView(debt: Debt.example)
    }
}
