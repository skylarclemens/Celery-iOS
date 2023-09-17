//
//  Category.swift
//  Celery
//
//  Created by Skylar Clemens on 9/1/23.
//

import Foundation
import SwiftUI

struct Category: Codable, Hashable {
    let name: String
    let color: Int
    var colorUInt: UInt {
        UInt(color)
    }
    
    static let categoryList: [String: Category] = [
        "Category": Category(name: "Category", color: 0x6A9B5D),
        "Transportation": Category(name: "Transportation", color: 0x5088D1),
        "Travel": Category(name: "Travel", color: 0x5088D1),
        "Food": Category(name: "Food", color: 0x5088D1),
        "Shopping": Category(name: "Shopping", color: 0x5088D1),
        "Subscriptions": Category(name: "Subscriptions", color: 0x5088D1),
        "Entertainment": Category(name: "Entertainment", color: 0x9384E0),
        "Gifts": Category(name: "Gifts", color: 0x9384E0),
        "Personal Care": Category(name: "Personal Care", color: 0x9384E0),
        "Drinks": Category(name: "Drinks", color: 0x9384E0),
        "Rent": Category(name: "Rent", color: 0xF2A54B),
        "Work": Category(name: "Work", color: 0xF2A54B),
        "Home": Category(name: "Home", color: 0xF2A54B),
        "Furniture": Category(name: "Furniture", color: 0xF2A54B),
        "Utilities": Category(name: "Utilities", color: 0xF2A54B),
        "Pets": Category(name: "Pets", color: 0xF2A54B),
        "Maintenance": Category(name: "Maintenance", color: 0xF2A54B)
    ]
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
