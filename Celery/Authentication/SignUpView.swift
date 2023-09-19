//
//  SignUpView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI
import AuthenticationServices

private enum FocusableField: Hashable {
    case email
    case password
    case displayName
    case confirmPassword
}

struct SignUpView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var supabaseManager: SupabaseManager
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @FocusState private var focusedInput: FocusableField?
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 16) {
                    Image(systemName: "at")
                    TextField("Email", text: $authViewModel.email)
                        .focused($focusedInput, equals: .email)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .onSubmit {
                            self.focusedInput = .password
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.secondary.opacity(0.25), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
                )
                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                    SecureField("Password", text: $authViewModel.password)
                        .focused($focusedInput, equals: .password)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .onSubmit {
                            self.focusedInput = .confirmPassword
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.secondary.opacity(0.25), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.background))
                )
                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                    SecureField("Confirm password", text: $authViewModel.confirmPassword)
                        .focused($focusedInput, equals: .confirmPassword)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .onSubmit {
                            self.focusedInput = .displayName
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.secondary.opacity(0.25), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
                )
                HStack(spacing: 16) {
                    Image(systemName: "person")
                    TextField("Display name", text: $authViewModel.displayName)
                        .focused($focusedInput, equals: .displayName)
                        .submitLabel(.done)
                        .onSubmit {
                            self.focusedInput = nil
                            signUpWithEmailPassword()
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.secondary.opacity(0.25), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.background))
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            Button {
                signUpWithEmailPassword()
            } label: {
                if authViewModel.authState != .authenticating {
                    Text("Sign up")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.regular)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                }
            }.buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty || authViewModel.confirmPassword.isEmpty || authViewModel.displayName.isEmpty || authViewModel.password != authViewModel.confirmPassword)
                .tint(Color(red: 0.42, green: 0.61, blue: 0.36))
                .padding(.top, 8)
            HStack(alignment: .center, spacing: 16) {
                Rectangle()
                    .fill(.secondary.opacity(0.25))
                    .frame(maxWidth: .infinity, maxHeight: 1)
                Text("or")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                Rectangle()
                    .fill(.secondary.opacity(0.25))
                    .frame(maxWidth: .infinity, maxHeight: 1)
            }
            .padding(.vertical, 8)
            /*SignInWithAppleButton(.signUp) { request in
                authViewModel.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                authViewModel.signInWithApple(result)
            }
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))*/
            HStack {
                Text("Already have an account?")
                Button {
                    authViewModel.currentAuthType = .login
                } label: {
                    Text("Log in")
                        .font(.headline)
                }
                .tint(Color(red: 0.42, green: 0.61, blue: 0.36))
            }
            .padding(.top)
        }
        .padding(.horizontal)
    }
    
    private func signUpWithEmailPassword() {
        Task {
            //await authViewModel.signUpWithEmailPassword()
        }
    }
}

#Preview {
    Group {
        SignUpView()
            .environmentObject(AuthenticationViewModel())
        /*SignUpView()
            .environmentObject(AuthenticationViewModel())
            .environment(\.colorScheme, .dark)*/
    }
}
