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
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tabItem {
                                Image(systemName: "house")
                            }.tag(0)
                        Text("")
                            .tabItem {
                                HStack(alignment: .center, spacing: 0) {
                                    Image(systemName: "plus")
                                        .foregroundStyle(.white)
                                }
                                .padding(0)
                                .frame(width: 52, height: 52, alignment: .center)
                                .background(Color(red: 0.42, green: 0.61, blue: 0.36))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                )
                            }.tag(1)
                        FriendsView()
                            .tabItem {
                                Image(systemName: "person.2")
                            }.tag(2)
                    }
                    .tint(.primary.opacity(0.66))
                    .onChange(of: selectedTab) { index in
                        if index == 1 {
                            self.openCreateExpense = true
                            self.selectedTab = self.prevSelectedTab
                        } else if openCreateExpense == false {
                            self.prevSelectedTab = index
                        }
                    }
                    Button {
                        selectedTab = 1
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                                .shadow(radius: 10)
                        }
                    }.frame(width: 52, height: 52, alignment: .center)
                    .background(Color(red: 0.42, green: 0.61, blue: 0.36))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 2)
                    )
                    .padding(.bottom, 5)
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
