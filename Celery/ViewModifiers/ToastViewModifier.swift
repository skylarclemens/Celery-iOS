//
//  ToastViewModifier.swift
//  Celery
//
//  Created by Skylar Clemens on 10/30/23.
//

import SwiftUI

struct ToastViewModifier<ToastContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let toastContent: () -> ToastContent
    
    init(
        isPresented: Binding<Bool>,
        content toastContent: @escaping () -> ToastContent
    ) {
        self._isPresented = isPresented
        self.toastContent = toastContent
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    toastContent()
                        .offset(y: -80)
                }
            }
            .onChange(of: isPresented) { newValue in
                if newValue == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
    }
}
