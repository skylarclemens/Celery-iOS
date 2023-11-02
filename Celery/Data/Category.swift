//
//  Category.swift
//  Celery
//
//  Created by Skylar Clemens on 9/1/23.
//

import Foundation
import SwiftUI

struct Category: Hashable {
    let name: String
    let color: Color
    
    static let categoryList: [Category] = [
        Category(name: "General", color: Color("green")),
        Category(name: "Transportation", color: Color("blue")),
        Category(name: "Travel", color: Color("blue")),
        Category(name: "Food", color: Color("blue")),
        Category(name: "Shopping", color: Color("blue")),
        Category(name: "Subscriptions", color: Color("blue")),
        Category(name: "Entertainment", color: Color("purple")),
        Category(name: "Gifts", color: Color("purple")),
        Category(name: "Personal Care", color: Color("purple")),
        Category(name: "Drinks", color: Color("purple")),
        Category(name: "Rent", color: Color("orange")),
        Category(name: "Work", color: Color("orange")),
        Category(name: "Home", color: Color("orange")),
        Category(name: "Furniture", color: Color("orange")),
        Category(name: "Utilities", color: Color("orange")),
        Category(name: "Pets", color: Color("orange")),
        Category(name: "Maintenance", color: Color("orange"))
    ]
}
