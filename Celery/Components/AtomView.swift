//
//  AtomView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/25/23.
//

import SwiftUI

struct AtomView<Content: View>: View {
    private let atom: () -> Content?
    @State var atomColor: Color
    var showAtomColor: Bool
    
    init(atomColor: Color = .layoutGreen, showAtomColor: Bool = true) where Content == EmptyView {
        self.atomColor = atomColor
        self.showAtomColor = showAtomColor
        self.atom = { EmptyView() }
    }
    
    init(atomColor: Color = .layoutGreen, showAtomColor: Bool = true, @ViewBuilder atom: @escaping () -> Content? = {nil}) {
        self.atomColor = atomColor
        self.showAtomColor = showAtomColor
        self.atom = atom
    }
    
    var body: some View {
        ZStack {
            if showAtomColor {
                Circle()
                    .fill(atomColor
                        .shadow(.inner(color: .black.opacity(0.05), radius: 0, y: 3)))
            }
            if let atom = atom() {
                atom
            }
            Circle()
                .stroke(.background.opacity(0.35), lineWidth: 8)
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
    }
}

#Preview {
    AtomView()
}
