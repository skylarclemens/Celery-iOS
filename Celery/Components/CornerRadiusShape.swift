//
//  CornerRadiusView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/30/23.
//

import SwiftUI

struct CornerRadiusShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCorners(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

#Preview {
    VStack{
        Text("Rounded corners")
            .foregroundStyle(.background)
            .font(.headline)
            .padding()
            .background(.blue.gradient)
            .roundedCorners(16, corners: [.topLeft, .topRight, .bottomLeft])
    }
}
