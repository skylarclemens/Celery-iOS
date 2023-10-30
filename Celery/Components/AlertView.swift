//
//  AlertView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/30/23.
//

import SwiftUI

struct ActionAlertView: View {
    @Binding var isSuccess: Bool
    var successTitle: String?
    var successMessage: String?
    var errorMessage: String?
    
    init(isSuccess: Binding<Bool>, successTitle: String? = nil, successMessage: String? = nil, errorMessage: String? = nil) {
        self._isSuccess = isSuccess
        self.successTitle = successTitle
        self.successMessage = successMessage
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        HStack(spacing: isSuccess ? 14 : 8) {
            if isSuccess {
                AnimatedCheckmark(color: Color.primaryAction)
                    .scaleEffect(0.8)
                if let successTitle = successTitle {
                    Text(successTitle)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                }
                if let successMessage = successMessage {
                    Text(successMessage)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                }
            } else {
                Image(systemName: "x.circle.fill")
                    .foregroundColor(.red)
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThickMaterial)
                .shadow(color: .black.opacity(0.05), radius: 3, y: 3)
        )
        .transition(.moveAndFade)
    }
}

struct CustomAlertView<Label: View>: View {
    let label: () -> Label
    
    init(label: @escaping () -> Label) {
        self.label = label
    }
    
    var body: some View {
        VStack {
            label()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThickMaterial)
                .shadow(color: .black.opacity(0.05), radius: 3, y: 3)
        )
        .transition(.moveAndFade)
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .scale(scale: 0.5).combined(with: .opacity)
        )
    }
}

#Preview {
    VStack {
        ActionAlertView(isSuccess: .constant(true))
        CustomAlertView() {
            HStack(spacing: 20) {
                AnimatedCheckmark(color: Color.primaryAction)
                    .scaleEffect(0.8)
                VStack {
                    Text("Test")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .opacity(0.9)
                    Text("Test message")
                        .font(.system(size: 14, design: .rounded))
                        .opacity(0.6)
                }
            }
        }
    }
}
