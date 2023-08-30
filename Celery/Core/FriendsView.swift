//
//  FriendsView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI

struct FriendsView: View {
    @State var showFriendSearch: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Text("Friends list")
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                Button("Add friend", systemImage: "person.crop.circle.badge.plus") {
                    showFriendSearch = true
                }
                .tint(Color(red: 0.42, green: 0.61, blue: 0.36))
            }
        }
        .sheet(isPresented: $showFriendSearch) {
            QueryUsersView()
        }
    }
}

#Preview {
    FriendsView()
}
