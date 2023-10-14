//
//  PayView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/1/23.
//

import SwiftUI

struct PayView: View {
    @Environment(\.dismiss) var dismiss
    var creditor: UserInfo?
    var debtor: UserInfo?
    var amount: Double
    
    private let currencyFormat: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 4) {
                    HStack(spacing: 16) {
                        UserPhotoView(size: 72, imagePath: creditor?.avatar_url)
                        UserPhotoView(size: 72, imagePath: debtor?.avatar_url)
                    }
                    .padding(.bottom, 8)
                    Group {
                        Text("You")
                            .fontWeight(.medium) +
                        Text(" paid ") +
                        Text("James")
                            .fontWeight(.medium)
                    }.font(.system(size: 24))
                    Text(amount, format: currencyFormat)
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.layoutGreen)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: UIColor.tertiarySystemGroupedBackground))
            )
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 8)
            Group {
                Button {
                    dismiss()
                } label: {
                    Text("Confirm")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.layoutGreen, lineWidth: 1))
                .padding(.top, 8)
                .tint(.primaryAction)
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .padding(.vertical, 8)
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    VStack {
        
    }
    .sheet(isPresented: .constant(true)) {
        PayView(amount: 10.0)
            .presentationDetents([.medium])
    }
}
