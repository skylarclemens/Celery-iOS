//
//  SignInView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/28/23.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    var body: some View {
        switch authViewModel.currentAuthType {
        case .login:
            LoginView()
        case .signUp:
            SignUpView()
        }
    }
}

#Preview {
    AuthenticationView()
}
