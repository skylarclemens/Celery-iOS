//
//  LoginView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @FocusState private var focusedInput: FocusableField?
    
    private enum FocusableField: Hashable {
      case email
      case password
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 16) {
                    Image(systemName: "at")
                    TextField("Email", text: $authViewModel.email)
                        .focused($focusedInput, equals: .email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.next)
                        .onSubmit {
                            self.focusedInput = .password
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.secondary.opacity(0.25), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.background))
                )
                HStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                    SecureField("Password", text: $authViewModel.password)
                        .focused($focusedInput, equals: .password)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .onSubmit {
                            self.focusedInput = nil
                            Task {
                                await authViewModel.signInWithEmailPassword()
                            }
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
                Task {
                    await authViewModel.signInWithEmailPassword()
                }
            } label: {
                if authViewModel.authState != .authenticating {
                    Text("Log in")
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
                .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty)
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
            /*SignInWithAppleButton(.signIn) { request in
                authViewModel.handleSignInWithAppleRequest(request)
            } onCompletion: { result in
                authViewModel.signInWithApple(result)
            }
            .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))*/
            HStack {
                Text("Need an account?")
                Button {
                    authViewModel.currentAuthType = .signUp
                } label: {
                    Text("Sign up")
                        .font(.headline)
                }
                .tint(Color(red: 0.42, green: 0.61, blue: 0.36))
            }
            .padding(.top)
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationViewModel())
}
