//
//  AuthViewModel.swift
//  Celery
//
//  Created by Skylar Clemens on 8/25/23.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

enum AuthState: Equatable {
    case authenticating
    case signedIn(User)
    case signedOut
}

enum AuthType {
    case login, signUp
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authState: AuthState = .signedOut
    @Published var displayName: String = ""
    @Published var currentUser: User?
    
    private let signInWithAppleHelper = SignInAppleHelper()
    private let signInWithEmailHelper = SignInEmailPasswordHelper()
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isValid = false
    @Published var errorMessage = ""
    
    @Published var currentAuthType: AuthType = .login
    
    init() {
        registerAuthStateHandler()
    }
    
    func restorePrevSignIn() {
        Task { [weak self] in
            if self?.authState == .signedOut {
                let state = await self?.signInWithAppleHelper.restorePrevSignIn()
                if case .signedIn(let user) = state {
                    self?.currentUser = user
                }
                self?.authState = state ?? .signedOut
            }
        }
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        return signInWithAppleHelper.handleSignInWithAppleRequest(request)
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, Error>) {
        Task { [weak self] in
            let state = await self?.signInWithAppleHelper.signInWithApple(result)
            if case .signedIn(let user) = state {
                self?.currentUser = user
                let currentUser = UserInfo(auth: user)
                try? await UserManager.shared.createNewUser(user: currentUser)
            }
            self?.authState = state ?? .signedOut
        }
    }
    
    func signInWithEmailPassword() async {
        self.authState = .authenticating
        do {
            let state = try await self.signInWithEmailHelper.signInWithEmailPassword(email: self.email, password: self.password)
            if case .signedIn(let user) = state {
                self.currentUser = user
                let currentUser = UserInfo(auth: user)
                try? await UserManager.shared.createNewUser(user: currentUser)
            }
            self.authState = state
        } catch {
            print(error)
            self.errorMessage = error.localizedDescription
            self.authState = .signedOut
        }
    }
    
    func signUpWithEmailPassword() async {
        self.authState = .authenticating
        do {
            let state = try await self.signInWithEmailHelper.signUpWithEmailPassword(email: self.email, password: self.password)
            if case .signedIn(let user) = state {
                self.currentUser = user
                let currentUser = UserInfo(auth: user)
                try? await UserManager.shared.createNewUser(user: currentUser)
            }
            self.authState = state
        } catch {
            print(error)
            self.errorMessage = error.localizedDescription
            self.authState = .signedOut
        }
    }

    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getUser() throws -> User? {
        guard case .signedIn(let user) = authState else {
            return nil
        }
        return user
    }
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                if let user = user {
                    self.currentUser = user
                    self.authState = .signedIn(user)
                    self.displayName = user.displayName ?? user.email ?? ""
                } else {
                    self.currentUser = nil
                    self.authState = .signedOut
                    self.displayName = ""
                }
            }
        }
    }
}

extension ASAuthorizationAppleIDCredential {
    func displayName() -> String {
        return self.fullName?.formatted() ?? ""
    }
}
