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
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: columns) {
                    if self.loading == .success,
                       let groups = model.groups {
                        if !groups.isEmpty {
                            ForEach(groups) { group in
                                NavigationLink(value: group) {
                                    GroupLinkView(group: group)
                                }
                                .buttonStyle(.plain)
                            }
                        } else {
                            Text("No groups")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .navigationDestination(for: GroupInfo.self) { value in
                    GroupView(group: value, path: $path)
                }
                .padding(.horizontal)
            }
            .background(
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .ignoresSafeArea()
            )
            .refreshable {
                await fetchGroups()
            }
            .navigationTitle("Groups")
            .navigationBarTitleDisplayMode(.inline)
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

struct GroupLinkView: View {
    @Environment(\.colorScheme) var colorScheme
    let group: GroupInfo

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                UserPhotoView(size: 40, imagePath: group.avatar_url, type: .group)
                Spacer()
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 30)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text(group.group_name ?? "Group")
                .font(.system(size: 16, weight: .medium))
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: 120, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    GroupLinkView(group: GroupInfo.example)
}
