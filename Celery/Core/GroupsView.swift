//
//  GroupsView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State var groups: [GroupInfo]?
    @State var loading: LoadingState = .loading
    
    @State var openCreateGroup: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    if self.loading == .success {
                        if let groups = self.groups {
                            ForEach(groups) { group in
                                NavigationLink {
                                    GroupView(group: group)
                                } label: {
                                    HStack(spacing: 12) {
                                        UserPhotoView(size: 40, imagePath: group.avatar_url, type: .group)
                                        Text(group.group_name ?? "Unknown group")
                                    }
                                }
                            }
                            Section {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 0)
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .refreshable {
                    try? await fetchGroups()
                }
            }
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        openCreateGroup = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Create new group")
                    }
                }
            }
            .sheet(isPresented: $openCreateGroup) {
                CreateGroupView()
            }
        }
        .task {
            try? await fetchData()
        }
    }
    
    func fetchData() async throws {
        self.loading = .loading
        do {
            if self.groups == nil {
                try await fetchGroups()
            }
            self.loading = .success
        } catch {
            self.loading = .error
        }
    }
    
    func fetchGroups() async throws {
        self.groups = try? await SupabaseManager.shared.getUsersGroups()
    }
}

#Preview {
    NavigationStack {
        GroupsView()
            .environmentObject(AuthenticationViewModel())
    }
}
