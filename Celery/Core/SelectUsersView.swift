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
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = SelectUsersViewModel()
    private var initialSelectedUsers: [UserInfo]
    private var initialSelectedGroup: GroupInfo?
    @Binding var selectedUsers: [UserInfo]
    @Binding var selectedGroup: GroupInfo?
    
    @State var selectedGroupMembers: [UserInfo]?
    @State var usersGroups: [GroupInfo]?
    
    @FocusState private var focusedInput: FocusableField?
    private enum FocusableField: Hashable {
        case searchBar
    }
    
    var showGroups: Bool
    
    init(selectedUsers: Binding<[UserInfo]>, selectedGroup: Binding<GroupInfo?>? = nil, showGroups: Bool = false) {
        self._selectedUsers = selectedUsers
        self._selectedGroup = selectedGroup ?? Binding.constant(nil)
        self.initialSelectedUsers = selectedUsers.wrappedValue
        self.initialSelectedGroup = selectedGroup?.wrappedValue
        self.showGroups = showGroups
    }
    
    var body: some View {
        NavigationStack {
            VStack {
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
                if showGroups,
                    let usersGroups,
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
                if let selectedGroupMembers = selectedGroupMembers {
                    List {
                        ForEach(selectedGroupMembers.filter {
                            if viewModel.debouncedQuery == "" {
                                return true
                            } else {
                                return $0.name?.localizedLowercase.localizedStandardContains(viewModel.debouncedQuery.localizedLowercase) ?? false
                            }
                        }) { user in
                            if !authViewModel.isCurrentUser(userId: user.id) {
                                let userSelected = selectedUsers.firstIndex(where: { $0.id == user.id })
                                Button {
                                    if let userSelected {
                                        selectedUsers.remove(at: userSelected)
                                    } else {
                                        selectedUsers.append(user)
                                    }
                                } label: {
                                    HStack {
                                        UserPhotoView(size: 40, imagePath: user.avatar_url)
                                        Text(user.name ?? "Unknown user")
                                        Spacer()
                                        if userSelected != nil {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.blue)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.inset)
                }
                if let queriedUsers = viewModel.queriedUsers,
                   !queriedUsers.isEmpty,
                    selectedGroup == nil {
                    VStack(alignment: .leading) {
                        Text("People")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary.opacity(0.9))
                            .padding(.horizontal)
                        List {
                            ForEach(queriedUsers) { user in
                                let userSelected = selectedUsers.firstIndex(where: { $0.id == user.id })
                                Button {
                                    if let userSelected {
                                        selectedUsers.remove(at: userSelected)
                                    } else {
                                        selectedUsers.append(user)
                                    }
                                } label: {
                                    HStack {
                                        UserPhotoView(size: 40, imagePath: user.avatar_url)
                                        Text(user.name ?? "Unknown user")
                                        Spacer()
                                        if userSelected != nil {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.blue)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.inset)
                    }
                }
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
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        selectedUsers = initialSelectedUsers
                        selectedGroup = initialSelectedGroup
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
    SelectUsersView(selectedUsers: .constant([]), showGroups: true)
}
