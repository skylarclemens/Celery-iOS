//
//  CategoryPickerView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/25/23.
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var category: String
    let categoryNames = Category.categoryList.map { category in
        category.key
    }
    
    var body: some View {
        VStack {
            AtomView() {
                Image(category == "Category" ? "General" : category)
                    .resizable()
                    .frame(maxWidth: 60, maxHeight: 60)
            }
            Picker("Category", selection: $category) {
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
    CategoryPickerView(category: .constant("Category"))
}
