//
//  AuthHelper.swift
//  Celery
//
//  Created by Skylar Clemens on 10/26/23.
//

import Foundation
import AuthenticationServices
import CryptoKit
import GoTrue

// MARK: Sign in with Apple Authentication
@MainActor
final class SignInWithAppleHelper {
    private var currentNonce: String?
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
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
                
                let session = try? await SupabaseManager.shared.client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idTokenString, nonce: nonce))
                return .signedIn
            } else {
                return .signedOut
            }
        case .failure(let error):
            print(error.localizedDescription)
            return .signedOut
        }
    }
}

extension SignInWithAppleHelper {
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
