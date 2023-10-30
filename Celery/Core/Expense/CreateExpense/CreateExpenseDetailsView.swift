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
    var currentUser: UserInfo?
    
    @FocusState private var focusedInput: FocusedField?
    private enum FocusedField: Hashable {
        case name, amount
    }
    private let currencyFormat: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    
    var locale: Locale = .current
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        return formatter
    }
    
    @Binding var isOpen: Bool
    
    var invalidForm: Bool {
        newExpense.name.isEmpty || newExpense.amount == 0
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemGroupedBackground))
                .ignoresSafeArea()
            VStack {
                Spacer()
                Section {
                    HStack {
                        TextField("Expense name", text: $newExpense.name, axis: .horizontal)
                            .font(.system(size: 28, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.never)
                            .submitLabel(.done)
                            .focused($focusedInput, equals: .name)
                            .onSubmit {
                                self.focusedInput = nil
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
                        CurrencyTextField(value: $newExpense.amount, formatter: numberFormatter)
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
                            .frame(height: 60)
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
                    NavigationLink {
                        CreateExpenseSplitView(newExpense: newExpense, currentUser: currentUser, isOpen: $isOpen)
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .font(.headline)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(invalidForm ? Color.secondary.opacity(0.25) : Color.layoutGreen, lineWidth: 1))
                    .padding(.top, 8)
                    .tint(.primaryAction)
                }
                .disabled(invalidForm)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color(uiColor: UIColor.secondaryLabel), Color(uiColor: UIColor.tertiarySystemFill))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateExpenseDetailsView(newExpense: NewExpense(), isOpen: .constant(true))
            .environmentObject(AuthenticationViewModel())
    }
}
