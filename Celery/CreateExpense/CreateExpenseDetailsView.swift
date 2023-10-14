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
    var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    @Binding var isOpen: Bool

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
                        TextField("$0.00", value: $newExpense.amount, formatter: numberFormatter)
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
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.layoutGreen, lineWidth: 1))
                    .padding(.top, 8)
                    .tint(.primaryAction)
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(uiColor: UIColor.secondaryLabel), Color(uiColor: UIColor.tertiarySystemFill))
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focusedInput = .name
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 17))
                }.disabled(focusedInput == .name)
                    .tint(.layoutGreen)
                Button {
                    focusedInput = .amount
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 17))
                }.disabled(focusedInput == .amount)
                    .tint(.layoutGreen)
                Spacer()
                Button {
                    focusedInput = nil
                } label: {
                    Text("Done")
                        .font(.system(size: 15, weight: .semibold))
                }
                .tint(.layoutGreen)
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
