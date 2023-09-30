//
//  CategoryPickerView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/25/23.
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var category: String
    var selectedCategory: Category? {
        Category.categoryList.first(where: {
            $0.name == category
        })
    }
    let categoryNames = Category.categoryList.map { category in
        category.name
    }
    
    var body: some View {
        VStack {
            AtomView(showAtomColor: false) {
                Circle()
                    .fill(Color(hex: selectedCategory?.colorUInt ?? 0x6A9B5D)
                        .shadow(.inner(color: .black.opacity(0.05), radius: 0, y: 3)))
                Image(category == "Category" ? "General" : category)
                    .resizable()
                    .frame(maxWidth: 60, maxHeight: 60)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
            }
            Picker("Category", selection: $category.animation(.spring(duration: 0.5))) {
                Text("Category").tag("Category")
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
    ZStack {
        Rectangle()
            .fill(Color(uiColor: UIColor.systemGroupedBackground))
        CategoryPickerView(category: .constant("Category"))
    }
}
