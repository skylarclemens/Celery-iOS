//
//  WelcomeView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/31/23.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Binding var openAuthView: Bool
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Welcome to")
                Text("Celery")
                    .foregroundStyle(Color(red: 0.42, green: 0.61, blue: 0.36))
            }
            .font(.system(size: 40, weight: .semibold, design: .rounded))
            Spacer()
            Button {
                authViewModel.currentAuthType = .login
                openAuthView = true
            } label: {
                Text("Log in")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color(red: 0.42, green: 0.61, blue: 0.36))
            Button {
                authViewModel.currentAuthType = .signUp
                openAuthView = true
            } label: {
                Text("Sign up")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(red: 0.42, green: 0.61, blue: 0.36))
                    .frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.white)
        }
        .padding()
    }
}

#Preview {
    WelcomeView(openAuthView: .constant(false))
        .environmentObject(AuthenticationViewModel())
}
