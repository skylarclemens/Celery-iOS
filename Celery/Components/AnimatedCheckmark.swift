//
//  AnimatedCheckmark.swift
//  Celery
//
//  Created by Skylar Clemens on 10/27/23.
//

import SwiftUI

struct Checkmark: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
        
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0.5 * height))
        path.addLine(to: CGPoint(x: 0.4 * width, y: 1.0 * height))
        path.addLine(to: CGPoint(x: width, y: 0))
        return path
    }
}

struct AnimatedCheckmark: View {
    var animationDuration: Double = 0.75
    var color: Color = .white
    @State private var innerTrimEnd: CGFloat = 0
    @State private var scale = 1.0
    var body: some View {
        HStack {
            Checkmark()
                .trim(from: 0, to: innerTrimEnd)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 15, height: 15)
                .scaleEffect(scale)
        }
        .onAppear {
            animate()
        }
    }
    
    func animate() {
        withAnimation(
            .easeInOut(duration: animationDuration * 0.7)
        ) {
            innerTrimEnd = 1.0
        }
        
        withAnimation(
            .linear(duration: animationDuration * 0.2)
            .delay(animationDuration * 0.6)
        ) {
            scale = 1.1
        }
        
        withAnimation(
            .linear(duration: animationDuration * 0.1)
            .delay(animationDuration * 0.9)
        ) {
            scale = 1
        }
    }
}

#Preview {
    AnimatedCheckmark()
}
