//
//  SupabaseAuthViewModel.swift
//  Celery
//
//  Created by Skylar Clemens on 9/19/23.
//

import Foundation
import SwiftUI
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
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var displayName: String = ""
    @Published var isValid = false
    @Published var errorMessage = ""
    
    @Published var currentAuthType: AuthType = .login
    
    private let supabase = SupabaseManager.shared.client
    
    init() {
        Task {
            try? await initializeSessionListener()
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
