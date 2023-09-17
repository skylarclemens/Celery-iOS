//
//  FirebaseAuthService.swift
//  Celery
//
//  Created by Skylar Clemens on 8/25/23.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

// MARK: Sign in with Apple Authentication

@MainActor
final class SignInAppleHelper {
    private var currentNonce: String?
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func restorePrevSignIn() async -> AuthState {
        return await withCheckedContinuation { continuation in
            if let currentUser = Auth.auth().currentUser {
                continuation.resume(returning: .signedIn(currentUser))
            } else {
                continuation.resume(returning: .signedOut)
            }
        }
    }
    
    func signInWithApple(_ result: Result<ASAuthorization, Error>) async -> AuthState {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    return .signedOut
                }
                
                guard let idToken = appleIDCredential.identityToken else {
                    print("Unable to get Apple ID token")
                    return .signedOut
                }
                
                guard let idTokenString = String(data: idToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(idToken.debugDescription)")
                    return .signedOut
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                
                return await signInOnFirebase(with: credential, appleIDCredential: appleIDCredential)
            } else {
                return .signedOut
            }
        case .failure(let error):
            print(error.localizedDescription)
            return .signedOut
        }
    }
    
    func signInOnFirebase(with credential: AuthCredential, appleIDCredential: ASAuthorizationAppleIDCredential) async -> AuthState {
        do {
            let authDataResult = try await Auth.auth().signIn(with: credential)
            let user = authDataResult.user
            await updateAppleDisplayName(for: user, with: appleIDCredential)
            return .signedIn(user)
        } catch {
            print("Error authenticating: \(error.localizedDescription)")
            return .signedOut
        }
    }
    
    func updateAppleDisplayName(for user: User, with appleIDCredential: ASAuthorizationAppleIDCredential) async {
        if let currentDisplayName = Auth.auth().currentUser?.displayName,
           !currentDisplayName.isEmpty {
            
        } else {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = appleIDCredential.displayName()
            do {
                try await changeRequest.commitChanges()
            } catch {
                print("Unable to update current user's display name: \(error.localizedDescription)")
            }
        }
    }
}

extension SignInAppleHelper {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

@MainActor
final class SignInEmailPasswordHelper {
    func signInWithEmailPassword(email: String, password: String) async throws -> AuthState {
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = authDataResult.user
            return .signedIn(user)
        } catch {
            print(error)
            return .signedOut
        }
    }
    
    func signUpWithEmailPassword(email: String, password: String, displayName: String) async throws -> AuthState {
        do {
            let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = authDataResult.user
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            return .signedIn(user)
        } catch {
            print(error)
            return .signedOut
        }
    }
}
