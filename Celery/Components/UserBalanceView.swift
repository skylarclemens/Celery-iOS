//
//  UserBalanceView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/20/23.
//

import SwiftUI

struct UserBalanceView: View {
    @Environment(\.colorScheme) var colorScheme
    var balanceOwed: Double
    var balanceOwe: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("You're owed")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.layoutGreen)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(Color.layoutGreen)
                }
                Text(balanceOwed, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .contentTransition(.numericText())
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.secondary.opacity(colorScheme == .light ? 0.125 : 0.5), lineWidth: 0.5)
            )
            VStack(alignment: .leading) {
                HStack {
                    Text("You owe")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.layoutRed)
                    Spacer()
                    Image(systemName: "arrow.down.left")
                        .foregroundStyle(Color.layoutRed)
                }
                Text(balanceOwe, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .contentTransition(.numericText())
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.secondary.opacity(colorScheme == .light ? 0.125 : 0.5), lineWidth: 0.5)
            )
        }
    }
}

#Preview {
    UserBalanceView(balanceOwed: 20.00, balanceOwe: 10.00)
}
