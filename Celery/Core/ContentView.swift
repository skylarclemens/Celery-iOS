//
//  ContentView.swift
//  Celery
//
//  Created by Skylar Clemens on 7/12/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var openAuthView: Bool = false
    var body: some View {
        Group {
            switch authViewModel.authState {
            case .signedIn:
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                    CreateExpenseView()
                        .tabItem {
                            Label("Add", systemImage: "plus")
                        }
                    FriendsView()
                        .tabItem {
                            Label("Friends", systemImage: "person.2")
                        }
                }
            case .signedOut, .authenticating:
                VStack {
                    Spacer()
                    VStack {
                        Text("Welcome to")
                        Text("Celery")
                            .foregroundStyle(Color(red: 0.42, green: 0.61, blue: 0.36))
                    }
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    Spacer()
                    Button {
                        authViewModel.currentAuthType = .login
                        openAuthView = true
                    } label: {
                        Text("Log in")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(Color(red: 0.42, green: 0.61, blue: 0.36))
                    Button {
                        authViewModel.currentAuthType = .signUp
                        openAuthView = true
                    } label: {
                        Text("Sign up")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color(red: 0.42, green: 0.61, blue: 0.36))
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(.white)
                }
                .padding()
                .sheet(isPresented: $openAuthView) {
                    AuthenticationView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
    }
}
