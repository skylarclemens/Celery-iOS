//
//  ContentView.swift
//  Celery
//
//  Created by Skylar Clemens on 7/12/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var toastManager = ToastManager.shared
    
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
                            .toolbar(.hidden, for: .tabBar)
                        Text("")
                            .tabItem {
                                HStack(alignment: .center, spacing: 0) {
                                    Image(systemName: "plus")
                                        .foregroundStyle(.white)
                                }
                            }.tag(1)
                        FriendsView()
                            .tabItem {
                                Image(systemName: "person.2")
                            }.tag(2)
                            .toolbar(.hidden, for: .tabBar)
                        GroupsView()
                            .tabItem {
                                Image(systemName: "person.3")
                            }.tag(3)
                            .toolbar(.hidden, for: .tabBar)
                    }
                    .onChange(of: selectedTab) { index in
                        if index == 1 {
                            self.openCreateExpense = true
                            self.selectedTab = self.prevSelectedTab
                        } else if openCreateExpense == false {
                            self.prevSelectedTab = index
                        }
                    }
                    VStack {
                        Spacer()
                        ZStack {
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
                                .background(
                                    Circle()
                                        .fill(
                                            .shadow(.inner(color: .black.opacity(0.25), radius: 0, y: -3))
                                        )
                                        .foregroundColor(.primaryAction)
                                )
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(colorScheme != .dark ? .white : .layoutGreen.opacity(0.75), lineWidth: 2)
                                )
                                .offset(y: -10)
                                .zIndex(2)
                            HStack {
                                Button {
                                    selectedTab = 0
                                } label: {
                                    Image(systemName: "house")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(selectedTab == 0 ? .secondary : .quaternary)
                                }
                                .tint(.secondary)
                                .padding(.horizontal, 20)
                                Button {
                                    selectedTab = 2
                                } label: {
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(selectedTab == 2 ? .secondary : .quaternary)
                                }
                                .tint(.secondary)
                                .padding(.horizontal, 20)
                                Spacer()
                                Button {
                                    selectedTab = 3
                                } label: {
                                    Image(systemName: "person.3.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(selectedTab == 3 ? .secondary : .quaternary)
                                }
                                .tint(.secondary)
                                .padding(.horizontal, 20)
                            }
                            .frame(maxWidth: 373, maxHeight: 52)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .inset(by: -1)
                                    .stroke(colorScheme != .dark ? Color(red: 0.87, green: 0.88, blue: 0.89) : Color(red: 0.22, green: 0.22, blue: 0.23), lineWidth: 2)
                            )
                            .zIndex(1)
                            VisualEffect(style: .systemChromeMaterial)
                                .offset(y: 45)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .blur(radius: 8)
                                .opacity(0.99)
                        }
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                .sheet(isPresented: $openCreateExpense) {
                    CreateExpenseView(isOpen: $openCreateExpense)
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
        .toast(isPresenting: $toastManager.showAlert) {
            ActionAlertView(isSuccess: $toastManager.isSuccess, successTitle: toastManager.successTitle, errorMessage: toastManager.errorMessage)
        }
        .environmentObject(toastManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(ToastManager())
    }
}

struct VisualEffect: UIViewRepresentable {
    @State var style : UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
}
