//
//  StatusBarModifier.swift
//  Celery
//
//  Created by Skylar Clemens on 9/16/23.
//

import Foundation
import SwiftUI

enum DisplayMode: Int {
    case system, light, dark
}

struct StatusBarSchemeModifier: ViewModifier {
    let colorScheme: ColorScheme
    let showBackground: Bool
    let backgroundColor: Color
    init(colorScheme: ColorScheme, showBackground: Bool = false, backgroundColor: Color = .clear) {
        self.colorScheme = colorScheme
        self.showBackground = showBackground
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        content
            .toolbarBackground(backgroundColor, for: .navigationBar)
            .toolbarBackground(showBackground ? .visible : .hidden, for: .navigationBar)
            .toolbarColorScheme(colorScheme, for: .navigationBar)
    }
}

extension View {
    func statusBarColorScheme(_ colorScheme: ColorScheme, showBackground: Bool = false, backgroundColor: Color = .clear) -> some View {
        modifier(StatusBarSchemeModifier(colorScheme: colorScheme, showBackground: showBackground, backgroundColor: backgroundColor))
    }
}
