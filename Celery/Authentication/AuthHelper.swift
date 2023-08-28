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
                return await signInOnFirebase(with: credential)
            } else {
                return .signedOut
            }
        case .failure(let error):
            print(error.localizedDescription)
            return .signedOut
        }
    }
    
    func signInOnFirebase(with credential: AuthCredential) async -> AuthState {
        do {
            let authDataResult = try await Auth.auth().signIn(with: credential)
            let user = authDataResult.user
            return .signedIn(user)
        } catch {
            print("Error authenticating: \(error.localizedDescription)")
            return .signedOut
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
