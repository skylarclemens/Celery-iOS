//
//  AuthViewModel.swift
//  Celery
//
//  Created by Skylar Clemens on 8/25/23.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authState: AuthState = .signedOut
    @Published var displayName: String = ""
    @Published var currentUser: User?
    
    private var signInWithAppleService: SignInAppleService { SignInAppleService.shared }
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init() {
        registerAuthStateHandler()
    }
    
    func restorePrevSignIn() {
        Task { [weak self] in
            if self?.authState == .signedOut {
                let state = await self?.signInWithAppleService.restorePrevSignIn()
                if case .signedIn(let user) = state {
                    self?.currentUser = user
                }
                self?.authState = state ?? .signedOut
            }
        }
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        return signInWithAppleService.handleSignInWithAppleRequest(request)
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, Error>) {
        Task { [weak self] in
            let state = await self?.signInWithAppleService.signInWithApple(result)
            if case .signedIn(let user) = state {
                self?.currentUser = user
            }
            self?.authState = state ?? .signedOut
        }
    }
    
    func updateDisplayName(for user: User, with appleIDCredential: ASAuthorizationAppleIDCredential) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName,
           !currentDisplayName.isEmpty {
            
        } else {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = appleIDCredential.displayName()
            do {
                try await changeRequest.commitChanges()
                self.displayName = Auth.auth().currentUser?.displayName ?? ""
            } catch {
                print("Unable to update current user's display name: \(error.localizedDescription)")
            }
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getUser() -> User? {
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
