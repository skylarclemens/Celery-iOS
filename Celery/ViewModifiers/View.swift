//
//  View.swift
//  Celery
//
//  Created by Skylar Clemens on 10/30/23.
//

import Foundation
import SwiftUI

extension View {
    func toast(isPresenting: Binding<Bool>,
               @ViewBuilder content: @escaping () -> some View) -> some View {
        modifier(ToastViewModifier(isPresented: isPresenting, content: content))
    }
}
