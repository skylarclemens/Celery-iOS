//
//  SupabaseAuthViewModel.swift
//  Celery
//
//  Created by Skylar Clemens on 9/19/23.
//

import Foundation
import Supabase

enum AuthState: Equatable {
    case authenticating
    case signedIn(User)
    case signedOut
}

struct AppUser {
    let uid: String
    let email: String?
}

enum AuthType {
    case login, signUp
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authState: AuthState = .signedOut
    @Published var currentUser: User?
    @Published var session: Session?
    @Published var displayName: String = ""
    
    //private let signInWithAppleHelper = SignInAppleHelper()
    //private let signInWithEmailHelper = SignInEmailPasswordHelper()
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isValid = false
    @Published var errorMessage = ""
    
    @Published var currentAuthType: AuthType = .login
    private let supabase = SupabaseManager.shared.client
    
    /*func restorePrevSignIn() {
        Task { [weak self] in
            if self?.authState == .signedOut {
                self?.currentUser = supabase.auth.session.user
                self?.authState = state ?? .signedOut
            }
        }
    }*/
    
    func getCurrentSession() async throws {
        let session = try await supabase.auth.session
        print(session)
    }
    
    func signInWithEmailPassword() async {
        self.authState = .authenticating
        do {
            /*let state = try await self.signInWithEmailHelper.signInWithEmailPassword(email: self.email, password: self.password)
            if case .signedIn(let user) = state {
                self.currentUser = user
                let currentUser = UserInfo(auth: user)
                self.currentUserInfo = currentUser
                try? await UserManager.shared.createNewUser(user: currentUser)
            }
            self.authState = state*/
            let session = try await supabase.auth.signIn(email: email, password: password)
            print("### Session Info: \(session)")
            self.session = session
            self.currentUser = session.user
            self.authState = .signedIn(session.user)
        } catch {
            print("### Sign in error: \(error)")
            self.errorMessage = error.localizedDescription
            self.authState = .signedOut
        }
    }
}
