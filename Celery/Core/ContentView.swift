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
    
    @State var selectedTab = 0
    @State var prevSelectedTab = 0
    @State var openCreateExpense: Bool = false
    var body: some View {
        Group {
            switch authViewModel.authState {
            case .signedIn:
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }.tag(0)
                    Text("")
                        .tabItem {
                            Label("Add", systemImage: "plus")
                        }.tag(1)
                    FriendsView()
                        .tabItem {
                            Label("Friends", systemImage: "person.2")
                        }.tag(2)
                }
                .onChange(of: selectedTab) { index in
                    if index == 1 {
                        self.openCreateExpense = true
                        self.selectedTab = self.prevSelectedTab
                    } else if openCreateExpense == false {
                        self.prevSelectedTab = index
                    }
                }
                .sheet(isPresented: $openCreateExpense) {
                    CreateExpenseView()
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
