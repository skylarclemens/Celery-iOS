//
//  CreateExpenseView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

struct CreateExpenseView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var amount: Double = 0.0
    let currencyFormatter: FloatingPointFormatStyle<Double>.Currency = .currency(code: Locale.current.currency?.identifier ?? "USD")
    @State private var date = Date()
    @State private var paidBy: String = "None"
    @State private var category: String = "Category"
    
    @FocusState private var focusedInput: FocusedField?
    private enum FocusedField: Hashable {
        case name, amount
    }
    
    init() {
        // Inline Navigation Title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.label]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Section {
                        HStack {
                            TextField("Expense name", text: $name, axis: .horizontal)
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
                        CategoryPicker(category: $category)
                    }
                    Section {
                        HStack {
                            TextField("$0.00", value: $amount, format: currencyFormatter)
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
                    /*Section {
                     Picker("Paid by", selection: $paidBy) {
                     Text("None")
                     Text("Me").tag(authViewModel.currentUser?.uid ?? "")
                     }
                     }*/
                    Spacer()
                    Section {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 20))
                            DatePicker("Date", selection: $date, displayedComponents: .date).labelsHidden()
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
                                try await createNewExpense()
                                dismiss()
                            }
                        } label: {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                        }
                        .font(.headline)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.top, 8)
                    }.tint(Color(hex: 0x6A9B5D))
                }
                .padding()
            }
            .navigationTitle("Add expense")
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
            .onAppear {
                focusedInput = .name
            }
        }
    }
    
    func createNewExpense() async throws {
        do {
            let newExpense = Expense(id: UUID().uuidString, name: name, description: nil, amount: amount, payerID: paidBy, groupID: nil, category: nil, date: date, createdAt: Date())
            try await ExpenseManager.shared.createNewExpense(expense: newExpense)
        } catch {
            print(error)
        }
    }
}

struct CategoryPicker: View {
    @Binding var category: String
    let categoryNames = Category.categoryList.map { category in
        category.key
    }
    
    var body: some View {
        //ZStack {
            VStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: Category.categoryList[category]?.colorUInt ?? 0x6A9B5D))
                    Image(category)
                        .resizable()
                        .frame(maxWidth: 60, maxHeight: 60)
                    Circle()
                        .stroke(.white, lineWidth: 12)
                }
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .background {
                    ForEach(0..<6) { i in
                        let orbitalSize = 60 * Double(i) * 1.25 + 30 // Adjust this formula as needed
                        Circle()
                            .strokeBorder(.tertiary.opacity(0.33), lineWidth: 1, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            .frame(width: orbitalSize, height: orbitalSize)
                    }
                }
                .frame(maxWidth: .infinity)
                Picker("Category", selection: $category) {
                    ForEach(categoryNames, id: \.self) { name in
                        Text(name).tag(name)
                    }
                }.labelsHidden()
                    .background(.ultraThickMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.tertiary.opacity(0.75), lineWidth: 1, antialiased: true)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .offset(y: -25)
                    .tint(.secondary)
            }.frame(maxWidth: .infinity, maxHeight: 240)
    }
}

#Preview {
    CreateExpenseView()
        .environmentObject(AuthenticationViewModel())
}
