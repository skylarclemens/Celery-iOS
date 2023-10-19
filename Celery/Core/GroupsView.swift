//
//  GroupsView.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import SwiftUI

struct GroupsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var model: Model
    @State var loading: LoadingState = .loading
    
    @State var openCreateGroup: Bool = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    if self.loading == .success {
                        if let groups = model.groups {
                            ForEach(groups) { group in
                                NavigationLink(value: group) {
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
                .navigationDestination(for: GroupInfo.self) { value in
                    GroupView(group: value, path: $path)
                }
                .refreshable {
                    await fetchGroups()
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
                CreateGroupView(path: $path)
            }
        }
        .task {
            if model.groups == nil {
                self.loading = .loading
                await fetchGroups()
            } else {
                self.loading = .success
            }
        }
    }
    
    func fetchGroups() async {
        do {
            try await model.fetchGroups()
            self.loading = .success
        } catch {
            self.loading = .error
        }
    }
}

#Preview {
    NavigationStack {
        GroupsView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(Model())
    }
}
