//
//  FriendOverviewView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/22/23.
//

import SwiftUI

struct FriendOverviewView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
    var debts: [Debt]
    var user: UserInfo
    var sharedBalance: Double {
        calculateTotalBalance(debts: debts)
    }
    
    var body: some View {
        NavigationLink {
            ProfileView(user: user)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        UserPhotoView(size: 45, imagePath: user.avatar_url)
                        Text(user.name ?? "Unknown name")
                            .fontWeight(.medium)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .truncationMode(.tail)
                    }
                    Spacer()
                    if !debts.isEmpty {
                        VStack(alignment: .trailing) {
                            HStack(spacing: 0) {
                                Text("\(sharedBalance > 0 ? "You're owed" : "You owe")  ")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.primary)
                                Text(abs(sharedBalance), format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(sharedBalance >= 0 ? Color.layoutGreen : Color.layoutRed)
                                    )
                            }
                            Group {
                                Text("\(debts.count)")
                                    .fontWeight(.medium) +
                                Text(" active bill\(debts.count != 1 ? "s" : "")")
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule()
                                    .fill(Color(UIColor.secondarySystemBackground))
                                    .overlay(
                                        Capsule()
                                            .stroke(.secondary.opacity(0.33), lineWidth: 0.5)
                                    )
                            )
                        }
                    } else {
                        Text("No active bills")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .padding(.leading, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.secondary.opacity(colorScheme == .light ? 0.25 : 0.5), lineWidth: 0.5)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 4, y: 3)
            .padding(.bottom, 8)
        }
        .buttonStyle(.plain)
    }
}

extension FriendOverviewView {
    func calculateTotalBalance(debts: [Debt]?) -> Double {
        var total: Double = 0.00
        if let debts = debts,
           let currentUser = authViewModel.currentUserInfo {
            for debt in debts {
                let amount = debt.amount ?? 0.00
                if debt.paid ?? true {
                    continue
                }
                if debt.creditor?.id == currentUser.id {
                    total += amount
                } else {
                    total -= amount
                }
            }
        }
        return total
    }
}
