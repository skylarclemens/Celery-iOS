//
//  SupabaseAuthViewModel.swift
//  Celery
//
//  Created by Skylar Clemens on 9/19/23.
//

import Foundation
import SwiftUI
import Supabase
import AuthenticationServices

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
    case login, signUp, confirmEmail
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authState: AuthState = .authenticating
    @Published var currentUser: User?
    @Published var currentUserInfo: UserInfo?
    @Published var tempUserInfo: UserInfo?
    @Published var session: Session? = nil
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName: String = ""
    @Published var isValid = false
    @Published var errorMessage = ""
    
    @Published var currentAuthType: AuthType = .login
    
    private let supabase = SupabaseManager.shared.client
    private let signInWithAppleHelper = SignInWithAppleHelper()
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        return signInWithAppleHelper.handleSignInWithAppleRequest(request)
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, Error>) {
        Task { [weak self] in
            let state = await self?.signInWithAppleHelper.signInWithApple(result)
            self?.authState = state ?? .signedOut
        }
    }
    
    func signInWithEmailPassword() async {
        self.authState = .authenticating
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            self.currentUser = session.user
            self.authState = .signedIn
        } catch {
            print("### Sign in error: \(error)")
            self.errorMessage = error.localizedDescription
            self.authState = .signedOut
        }
    }
    
    func signUpWithEmailPassword() async {
        do {
            let authResponse = try await SupabaseManager.shared.client.auth.signUp(email: email, password: password, data: [
                "name": AnyJSON.string(displayName)
            ])
            if let responseUser = authResponse.user {
                let tempUser = UserInfo(id: responseUser.id, email: responseUser.email, name: responseUser.userMetadata["name"]?.value as? String, avatar_url: nil, updated_at: nil, username: nil)
                self.tempUserInfo = tempUser
            }
            
            self.currentAuthType = .confirmEmail
        } catch {
            print("### Sign up  error: \(error)")
            self.errorMessage = error.localizedDescription
            self.authState = .signedOut
        }
    }
    
    func initializeSessionListener() async throws {
        self.authState = .authenticating
        for await _ in supabase.auth.authEventChange {
            self.session = try? await supabase.auth.session
            if let user = self.session?.user {
                self.currentUser = user
                self.currentUserInfo = try await SupabaseManager.shared.getUser(userId: user.id)
                self.authState = .signedIn
            } else {
                self.resetValues()
                self.authState = .signedOut
            }
        }
    }
    
    func isCurrentUser(userId: UUID) -> Bool {
        if let currentUserInfo = self.currentUserInfo {
            return currentUserInfo.id == userId
        } else {
            return false
        }
    }
    
    func isCurrentUser(userId: String) -> Bool {
        if let currentUserInfo = self.currentUserInfo {
            return currentUserInfo.id.uuidString.uppercased() == userId.uppercased()
        } else {
            return false
        }
    }
    
    func getCurrentUserInfo() async throws -> UserInfo? {
        do {
            if let user = self.session?.user {
                let userInfo = try await SupabaseManager.shared.getUser(userId: user.id)
                return userInfo
            }
        } catch {
            print("Error getting current user info: \(error)")
        }
        return nil
    }
    
    func updateCurrentUserInfo(_ updatedInfo: UserInfo, emailChange: Bool) async throws {
        do {
            let updatedUser = try await SupabaseManager.shared.updateUserInfo(user: updatedInfo)
            if let updatedUser {
                self.currentUserInfo = updatedUser
            }
            if emailChange,
               let email = updatedInfo.email {
                try await SupabaseManager.shared.client.auth.update(user: UserAttributes(email: email))
            }
        } catch {
            print("Error updating user info: \(error)")
        }
    }
    
    func signOut() async throws {
        do {
            try await supabase.auth.signOut()
            self.authState = .signedOut
            resetValues()
        } catch {
            print("Error signing user out: \(error)")
        }
    }
    
    func resetValues() {
        self.currentUser = nil
        self.currentUserInfo = nil
        self.session = nil
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.displayName = ""
        self.isValid = false
        self.errorMessage = ""
    }
}
