//
//  SignInView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/28/23.
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var body: some View {
        VStack {
            SignInWithAppleButton(.signIn) { request in
                authViewModel.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                authViewModel.signInWithApple(result)
            }
            .frame(height: 50)
            .padding()
            Spacer()
        }
    }
}

#Preview {
    AuthenticationView()
}
