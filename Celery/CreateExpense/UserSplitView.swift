//
//  UserSplitView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/26/23.
//

import SwiftUI

struct UserSplitView: View {
    @ObservedObject var newExpense: NewExpense
    let user: UserInfo
    @Binding var amount: Double
    var isCurrentUser: Bool = false
    
    private let currencyFormat: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    var body: some View {
        HStack {
            UserPhotoView(size: 50, imagePath: user.avatar_url)
            VStack(alignment: .leading, spacing: 2) {
                Text(isCurrentUser ? "You" : user.name ?? "Unknown user")
                    .font(.system(size: 14))
            }
            VStack { Divider() }
                .padding(.horizontal, 8)
            switch newExpense.selectedSplit {
            case .equal:
                TextField("$0.00", value: $amount, format: currencyFormat)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 80)
                    .disabled(true)
            case .exact: EmptyView()
                TextField("$0.00", value: $amount, format: currencyFormat)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 80)
            }
        }
    }
}

#Preview {
    UserSplitView(newExpense: NewExpense(), user: UserInfo.example, amount: .constant(0.0))
}
