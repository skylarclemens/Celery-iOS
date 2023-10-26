//
//  VerifyAccountView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/26/23.
//

import SwiftUI

struct VerifyAccountView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var body: some View {
        VStack {
            if let tempUserInfo = authViewModel.tempUserInfo {
                Text("Thanks for signing up, \(tempUserInfo.name ?? "")!")
                    .font(.headline)
            } else {
                Text("Thanks for signing up!")
                    .font(.headline)
            }
            Text("Please check your email to confirm your account.")
        }
        .multilineTextAlignment(.center)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        )
        .shadow(color: .black.opacity(0.125), radius: 10, y: 4)
    }
}

#Preview {
    VerifyAccountView()
        .environmentObject(AuthenticationViewModel())
}
