//
//  CreateExpenseDetailsView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/25/23.
//

import SwiftUI

struct CreateExpenseDetailsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var newExpense: NewExpense
    
    @FocusState private var focusedInput: FocusedField?
    private enum FocusedField: Hashable {
        case name, amount
    }
    private let currencyFormat: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    var body: some View {
        VStack {
            Spacer()
            Section {
                HStack {
                    TextField("Expense name", text: $newExpense.name, axis: .horizontal)
                        .font(.system(size: 28, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .focused($focusedInput, equals: .name)
                        .onSubmit {
                            self.focusedInput = .amount
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.tertiary.opacity(0.75), lineWidth: 1, antialiased: true)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                                )
                        )
                    
                }.frame(maxWidth: .infinity)
                    .zIndex(1)
            }
            Section {
                CategoryPickerView(category: $newExpense.category)
            }
            Section {
                HStack {
                    TextField("$0.00", value: $newExpense.amount, format: currencyFormat)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .focused($focusedInput, equals: .amount)
                        .padding(.vertical,10)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.tertiary.opacity(0.75), lineWidth: 1, antialiased: true)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                                )
                        )
                        .frame(maxWidth: 160)
                }.frame(maxWidth: .infinity)
                    .zIndex(1)
            }
            Spacer()
            Section {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                    DatePicker("Date", selection: $newExpense.date, displayedComponents: .date).labelsHidden()
                }.padding(.leading, 8)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                            .shadow(color: .black.opacity(0.05), radius: 4)
                    )
                    .frame(maxWidth: .infinity)
            }
            Section {
                Button {
                    Task {
                        newExpense.currentTabIndex = 1
                    }
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .font(.headline)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.layoutGreen, lineWidth: 1))
                .padding(.top, 8)
                .tint(.primaryAction)
            }
        }
        .padding()
        .navigationTitle("Add new expense")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focusedInput = .name
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 17))
                }.disabled(focusedInput == .name)
                    .tint(Color(hex: 0x6A9B5D))
                Button {
                    focusedInput = .amount
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 17))
                }.disabled(focusedInput == .amount)
                    .tint(Color(hex: 0x6A9B5D))
                Spacer()
                Button {
                    focusedInput = nil
                } label: {
                    Text("Done")
                        .font(.system(size: 15, weight: .semibold))
                }
                .tint(Color(hex: 0x6A9B5D))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            CreateExpenseDetailsView(newExpense: NewExpense())
        }
    }
}
