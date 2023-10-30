//
//  TransactionsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var transactionsList: [Debt]?
    @Binding var state: LoadingState
    
    var body: some View {
        Section {
            if state == .success {
                if let transactionsList,
                   !transactionsList.isEmpty {
                    ForEach(transactionsList) { debt in
                        TransactionView(debt: debt)
                            .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    }
                } else {
                    Text("No expenses")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else if state == .loading {
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else if state == .error {
                VStack {
                    Text("Something went wrong!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        } header: {
            Text("Transactions")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary.opacity(0.9))
                .textCase(nil)
                .padding(.bottom, 8)
                .padding(.top, 5)
        }
    }
}

#Preview {
    NavigationStack {
        TransactionsView(transactionsList: .constant([Debt.example]), state: .constant(.success))
            .environmentObject(AuthenticationViewModel())
    }
}
