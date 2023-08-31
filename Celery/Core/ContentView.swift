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
            case .signedOut:
                WelcomeView(openAuthView: $openAuthView)
                .sheet(isPresented: $openAuthView) {
                    AuthenticationView()
                }
            case .authenticating:
                LaunchView()
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
