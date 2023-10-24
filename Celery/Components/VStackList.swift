//
//  VStackListView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/22/23.
//

import SwiftUI

struct VStackListSection <Content: View>: View {
    var content: () -> Content
    var header: String
    
    init(header: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.header = header
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(header)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .padding(.leading)
             LazyVStack {
                 content()
             }
             .padding(12)
             .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
             )
        }
    }
}

#Preview {
    VStackListSection(header: "Header") {
        Text("Hello, world!")
    }
}
