//
//  HomeView.swift
//  Celery
//
//  Created by Skylar Clemens on 7/21/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var amount = 11.38
    
    init() {
        // Inline Navigation Title
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.32, green: 0.46, blue: 0.3), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.35, green: 0.51, blue: 0.32), location: 0.32),
                                    Gradient.Stop(color: Color(red: 0.41, green: 0.61, blue: 0.36), location: 0.62),
                                    Gradient.Stop(color: Color(red: 0.51, green: 0.68, blue: 0.42), location: 0.78),
                                    Gradient.Stop(color: Color(red: 0.69, green: 0.81, blue: 0.52), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                            .shadow(.inner(color: .black.opacity(0.05), radius: 0, x: 0, y: -3))
                        )
                        .shadow(radius: 24)
                        .ignoresSafeArea()
                    VStack {
                        Text(amount, format: .currency(code: "USD"))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .kerning(0.96)
                            .foregroundStyle(
                                .white.gradient
                                    .shadow(.inner(color: .black.opacity(0.1), radius: 0, x: 0, y: -2))
                                    .shadow(.drop(color: .black.opacity(0.25), radius: 0, x: 0, y: 2))
                            )
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 0)
                    .background(.black.opacity(0.1))
                    .cornerRadius(16)
                }
                .frame(maxHeight: 140)
                TransactionsView()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        UserProfileView()
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.white)
                            .accessibilityLabel("Open user settings")
                    }
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
