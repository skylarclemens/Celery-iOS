//
//  HomeView.swift
//  Celery
//
//  Created by Skylar Clemens on 7/21/23.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var transactionsList: [Debt]? = nil
    @State var currentUser: UserInfo?
    
    @State var totalBalance = 0.00
    @State var balanceOwed = 0.00
    @State var balanceOwe = 0.00
    
    init() {
        // Inline Navigation Title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Color(uiColor: UIColor.systemGroupedBackground))
                        .ignoresSafeArea()
                    if colorScheme != .dark {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 0.32, green: 0.46, blue: 0.3), location: 0.21),
                                        Gradient.Stop(color: Color(red: 0.3, green: 0.46, blue: 0.28), location: 0.38),
                                        Gradient.Stop(color: Color(red: 0.29, green: 0.46, blue: 0.25), location: 0.45),
                                        Gradient.Stop(color: Color(red: 0.34, green: 0.52, blue: 0.31), location: 0.57),
                                        Gradient.Stop(color: Color(red: 0.41, green: 0.61, blue: 0.36), location: 0.70),
                                        Gradient.Stop(color: Color(red: 0.69, green: 0.81, blue: 0.52), location: 0.88)
                                    ],
                                    startPoint: UnitPoint(x: 0.5, y: -0.5),
                                    endPoint: UnitPoint(x: 0.5, y: 1.29)
                                )
                                .shadow(.inner(color: .black.opacity(0.05), radius: 0, x: 0, y: -3))
                            )
                            .roundedCorners(24, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                    } else {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 0.11, green: 0.11, blue: 0.12), location: 0.00),
                                        Gradient.Stop(color: Color(red: 0.14, green: 0.15, blue: 0.14), location: 0.43),
                                        Gradient.Stop(color: Color(red: 0.14, green: 0.21, blue: 0.13), location: 0.86),
                                        Gradient.Stop(color: Color(red: 0.19, green: 0.28, blue: 0.17), location: 1.00),
                                    ],
                                    startPoint: UnitPoint(x: 0.5, y: 0),
                                    endPoint: UnitPoint(x: 0.5, y: 1)
                                )
                                .shadow(.inner(color: .white.opacity(0.1), radius: 0, x: 0, y: -2))
                            )
                            .roundedCorners(24, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                    }
                    VStack {
                        Text(totalBalance, format: .currency(code: "USD"))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .kerning(0.96)
                            .foregroundStyle(.white
                                .shadow(.drop(color: .black.opacity(0.25), radius: 0, x: 0, y: 2)))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.1))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.layoutGreen.opacity(colorScheme != .dark ? 0 : 0.3), lineWidth: 1)
                    )
                }
                .frame(maxHeight: 120)
                TransactionsView(transactionsList: $transactionsList)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        UserSettingsView()
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.white)
                            .accessibilityLabel("Open user settings")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    
                }
            }
        }
        .tint(.white)
        .task {
            if let user = authViewModel.currentUserInfo {
                self.currentUser = user
            }
            if self.transactionsList == nil {
                self.transactionsList = try? await SupabaseManager.shared.getDebtsWithExpense()
                balanceCalc()
            }
        }
        .onAppear {
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
        }
        .onDisappear {
            UINavigationBar.appearance().titleTextAttributes = nil
        }
    }
    
    func balanceCalc() {
        if let transactionsList,
           let currentUser {
            for debt in transactionsList {
                let amount = debt.amount ?? 0.00
                if debt.paid ?? true {
                    continue
                }
                if debt.creditor?.id == currentUser.id {
                    self.totalBalance += amount
                    self.balanceOwed += amount
                } else {
                    self.totalBalance -= amount
                    self.balanceOwe += amount
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
    }
}
