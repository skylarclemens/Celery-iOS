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
    case signedIn
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
    @Published var authState: AuthState = .authenticating
    @Published var currentUser: User?
    @Published var currentUserInfo: UserInfo?
    @Published var session: Session? = nil
    
    //private let signInWithAppleHelper = SignInAppleHelper()
    //private let signInWithEmailHelper = SignInEmailPasswordHelper()
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName: String = ""
    @Published var isValid = false
    @Published var errorMessage = ""
    
    @Published var currentAuthType: AuthType = .login
    
    private let supabase = SupabaseManager.shared.client
    
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
            self.currentUser = session.user
            self.authState = .signedIn
        } catch {
            print("### Sign in error: \(error)")
            self.errorMessage = error.localizedDescription
            self.authState = .signedOut
        }
    }
    
    func initializeSessionListener() async throws {
        self.authState = .authenticating
        for await event in supabase.auth.authEventChange {
            let event = event
            self.session = try? await supabase.auth.session
            if let user = self.session?.user {
                self.currentUser = user
                self.authState = .signedIn
            } else {
                self.resetValues()
                self.authState = .signedOut
            }
        }
    }
    
    func resetValues() {
        self.currentUser = nil
        self.currentUserInfo = nil
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.displayName = ""
        self.isValid = false
        self.errorMessage = ""
    }
}
