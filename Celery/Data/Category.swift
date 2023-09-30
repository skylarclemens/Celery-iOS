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
    
    static let categoryList: [Category] = [
        Category(name: "General", color: 0x6A9B5D),
        Category(name: "Transportation", color: 0x5088D1),
        Category(name: "Travel", color: 0x5088D1),
        Category(name: "Food", color: 0x5088D1),
        Category(name: "Shopping", color: 0x5088D1),
        Category(name: "Subscriptions", color: 0x5088D1),
        Category(name: "Entertainment", color: 0x9384E0),
        Category(name: "Gifts", color: 0x9384E0),
        Category(name: "Personal Care", color: 0x9384E0),
        Category(name: "Drinks", color: 0x9384E0),
        Category(name: "Rent", color: 0xF2A54B),
        Category(name: "Work", color: 0xF2A54B),
        Category(name: "Home", color: 0xF2A54B),
        Category(name: "Furniture", color: 0xF2A54B),
        Category(name: "Utilities", color: 0xF2A54B),
        Category(name: "Pets", color: 0xF2A54B),
        Category(name: "Maintenance", color: 0xF2A54B)
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
