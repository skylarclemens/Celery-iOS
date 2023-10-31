//
//  SelectUsersView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/24/23.
//

import SwiftUI
import Combine

class SelectUsersViewModel: ObservableObject {
    private var disposeBag = Set<AnyCancellable>()
    
    @Published var query: String = ""
    @Published var debouncedQuery: String = ""
    @Published var queriedUsers: [UserInfo]?
    
    init() {
        self.debounceTextChanges()
    }
    
    private func debounceTextChanges() {
        $query
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink {
                self.debouncedQuery = $0
            }
            .store(in: &disposeBag)
    }
}

struct SelectUsersView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var model: Model
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = SelectUsersViewModel()
    @Binding var completedSelectedUsers: [UserInfo]
    @Binding var completedSelectedGroup: GroupInfo?
    
    @State private var selectedUsers: [UserInfo]
    @State private var selectedGroup: GroupInfo?
    
    @State var selectedGroupMembers: [UserInfo]?
    let existingGroupMembers: [UserInfo]?
    @State var usersGroups: [GroupInfo]?
    
    @FocusState private var focusedInput: FocusableField?
    private enum FocusableField: Hashable {
        case searchBar
    }
    
    var showGroups: Bool
    var selectToAdd: Bool
    
    init(users: Binding<[UserInfo]>, group: Binding<GroupInfo?>? = nil, existingGroupMembers: [UserInfo]? = nil, showGroups: Bool = false, selectToAdd: Bool = false) {
        self._completedSelectedUsers = users
        self._completedSelectedGroup = group ?? Binding.constant(nil)
        self._selectedUsers = State(initialValue: users.wrappedValue)
        self._selectedGroup = State(initialValue: group?.wrappedValue)
        self.existingGroupMembers = existingGroupMembers
        self.showGroups = showGroups
        self.selectToAdd = selectToAdd
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: Search bar
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                        TextField("Search", text: $viewModel.query)
                            .font(.system(size: 17))
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .focused($focusedInput, equals: .searchBar)
                            .submitLabel(.search)
                            .onSubmit {
                                self.focusedInput = nil
                            }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(UIColor.tertiarySystemFill))
                    )
                    .animation(.spring(duration: 0.25), value: focusedInput)
                    .onReceive(viewModel.$debouncedQuery) { newValue in
                        Task {
                            try? await handleSearch(newValue)
                        }
                    }
                    .overlay {
                        if !viewModel.query.isEmpty && focusedInput == .searchBar {
                            HStack {
                                Spacer()
                                Button {
                                    viewModel.query = ""
                                } label: {
                                    Image(systemName: "multiply.circle.fill")
                                }
                                .foregroundStyle(.tertiary)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    // MARK: Selected users and group
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Selected")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary.opacity(0.9))
                                .padding(.leading)
                            if let selectedGroup {
                                HStack {
                                    Text(selectedGroup.group_name ?? "Unknown group name")
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Button {
                                        self.selectedGroup = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color(uiColor: UIColor.secondaryLabel), Color(uiColor: UIColor.tertiarySystemFill))
                                    }
                                }
                                .font(.system(size: 14))
                                .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 8))
                                .background(Color(UIColor.systemGroupedBackground))
                                .clipShape(Capsule())
                            }
                            Spacer()
                            Button("Clear") {
                                self.selectedGroup = nil
                                self.selectedGroupMembers = nil
                                self.selectedUsers = self.selectedUsers.filter {
                                    authViewModel.isCurrentUser(userId: $0.id)
                                }
                            }
                            .font(.system(size: 14))
                            .padding(.trailing)
                        }
                        .frame(height: 34)
                        if !selectedUsers.isEmpty {
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ForEach(selectedUsers) { user in
                                        let userSelected = selectedUsers.firstIndex(where: { $0.id == user.id })
                                        VStack {
                                            ZStack(alignment: .topTrailing) {
                                                if !authViewModel.isCurrentUser(userId: user.id) {
                                                    Button {
                                                        if let userSelected {
                                                            selectedUsers.remove(at: userSelected)
                                                        }
                                                    } label: {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .font(.system(size: 16))
                                                            .foregroundStyle(Color(UIColor.label).opacity(0.5), Color(UIColor.systemGroupedBackground))
                                                    }
                                                    .zIndex(1)
                                                    .offset(x: 8)
                                                }
                                                UserPhotoView(size: 45, imagePath: user.avatar_url)
                                            }
                                            Text(authViewModel.isCurrentUser(userId: user.id) ? "You" : user.name ?? "Unknown name")
                                                .font(.system(size: 12))
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .truncationMode(.tail)
                                        }
                                        .frame(maxWidth: 60)
                                    }
                                }
                                .padding(.leading)
                                .padding(.bottom, 8)
                            }
                        }
                        Divider()
                    }
                    .padding(.top, 8)
                    
                    // MARK: User's groups
                    if showGroups,
                       let usersGroups,
                       !usersGroups.isEmpty,
                       selectedGroup == nil {
                        VStack(alignment: .leading) {
                            Text("Groups")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary.opacity(0.9))
                                .padding(.horizontal)
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ForEach(usersGroups.filter {
                                        if viewModel.debouncedQuery == "" {
                                            return true
                                        } else {
                                            return $0.group_name?.localizedLowercase.localizedStandardContains(viewModel.debouncedQuery.localizedLowercase) ?? false
                                        }
                                    }) { group in
                                        Button {
                                            Task {
                                                try? await handleAddGroupMembers(groupId: group.id)
                                                self.selectedGroup = group
                                                viewModel.query = ""
                                                viewModel.debouncedQuery = ""
                                            }
                                        } label: {
                                            HStack {
                                                UserPhotoView(size: 30, imagePath: group.avatar_url, type: .group)
                                                Text(group.group_name ?? "")
                                                    .truncationMode(.tail)
                                                    .lineLimit(1)
                                            }
                                            .padding(8)
                                            .padding(.trailing, 6)
                                            .background(Color(UIColor.systemGroupedBackground))
                                            .clipShape(Capsule())
                                            .shadow(color: .black.opacity(0.1), radius: 2, y: 2)
                                            .overlay(
                                                Capsule()
                                                    .stroke(.secondary.opacity(0.15), lineWidth: 1)
                                            )
                                            .frame(maxWidth: 240)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            }
                            .scrollIndicators(.hidden)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: Most recent users list
                    if let recentUsers = model.recentUsers,
                       !recentUsers.isEmpty,
                        selectedGroup == nil,
                       viewModel.debouncedQuery.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Recent")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary.opacity(0.9))
                                .padding(.horizontal)
                            LazyVStack(spacing: 0) {
                                ForEach(recentUsers) { user in
                                    SelectUserRowView(selectedUsers: $selectedUsers, user: user)
                                }
                            }
                        }
                    }
                    
                    // MARK: Group members list
                    // Shows members of the selected group
                    if let selectedGroupMembers = selectedGroupMembers,
                       selectedGroup != nil {
                        LazyVStack(spacing: 0) {
                            ForEach(selectedGroupMembers.filter {
                                if viewModel.debouncedQuery == "" {
                                    return true
                                } else {
                                    return $0.name?.localizedLowercase.localizedStandardContains(viewModel.debouncedQuery.localizedLowercase) ?? false
                                }
                            }) { user in
                                if !authViewModel.isCurrentUser(userId: user.id) {
                                    SelectUserRowView(selectedUsers: $selectedUsers, user: user)
                                }
                            }
                        }
                    }
                    
                    // MARK: Queried people selection list
                    if let queriedUsers = viewModel.queriedUsers,
                       !queriedUsers.isEmpty,
                       selectedGroup == nil {
                        VStack(alignment: .leading) {
                            Text("People")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary.opacity(0.9))
                                .padding(.horizontal)
                            LazyVStack(spacing: 0) {
                                ForEach(queriedUsers) { user in
                                    if selectToAdd,
                                       let existingGroupMembers,
                                       existingGroupMembers.contains(where: { $0.id == user.id }) {
                                        SelectUserRowView(selectedUsers: $selectedUsers, user: user, alreadyAdded: true)
                                            .disabled(true)
                                    } else {
                                        SelectUserRowView(selectedUsers: $selectedUsers, user: user)
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("Select people")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                focusedInput = .searchBar
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        //Saves the current selections to users/group bindings
                        self.completedSelectedUsers = self.selectedUsers
                        self.completedSelectedGroup = self.selectedGroup
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                if showGroups {
                    try? await fetchGroups()
                }
            }
        }
    }
    
    func fetchGroups() async throws {
        let groups = try? await SupabaseManager.shared.getUsersGroups()
        self.usersGroups = groups
    }
    
    func handleAddGroupMembers(groupId: UUID) async throws {
        do {
            let groupMembers = try await SupabaseManager.shared.getGroupMembers(groupId: groupId)
            if let groupMembers {
                self.selectedUsers = groupMembers
                self.selectedGroupMembers = groupMembers
            }
        } catch {
            print("Failed to fetch group members: \(error)")
        }
    }
    
    func handleSearch(_ query: String) async throws {
        do {
            if !query.isEmpty {
                viewModel.queriedUsers = try await SupabaseManager.shared.getUsersByQuery(value: query)
            } else {
                viewModel.queriedUsers = []
            }
        } catch {
            print("Failed to fetch search query results: \(error)")
        }
    }
}

#Preview {
    SelectUsersView(users: .constant([]), showGroups: true)
        .environmentObject(AuthenticationViewModel())
        .environmentObject(Model())
}

struct SelectUserRowView: View {
    @Binding var selectedUsers: [UserInfo]
    let user: UserInfo
    var userSelected: Array.Index? {
        selectedUsers.firstIndex(where: { $0.id == user.id })
    }
    var alreadyAdded: Bool = false
    
    var body: some View {
        Button {
            if let userSelected {
                selectedUsers.remove(at: userSelected)
            } else {
                selectedUsers.append(user)
            }
        } label: {
            HStack {
                UserPhotoView(size: 40, imagePath: user.avatar_url)
                    .padding(.leading)
                VStack {
                    Spacer()
                    HStack {
                        Text(user.name ?? "Unknown user")
                        Spacer()
                        if userSelected != nil || alreadyAdded {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(alreadyAdded ? Color.secondary : .blue)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.trailing)
                    Spacer()
                    Divider()
                }
            }
            .frame(height: 60)
        }
        .tint(.primary)
    }
}

#Preview {
    VStack {
        LazyVStack(spacing: 0) {
            SelectUserRowView(selectedUsers: .constant([UserInfo.example]), user: UserInfo.example)
            SelectUserRowView(selectedUsers: .constant([]), user: UserInfo.example)
        }
    }
}
