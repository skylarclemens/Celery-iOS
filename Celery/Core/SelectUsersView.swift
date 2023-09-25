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
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SelectUsersViewModel()
    @Binding var selectedUsers: [UserInfo]
    @FocusState private var focusedInput: FocusableField?
    private enum FocusableField: Hashable {
        case searchBar
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
                            if !newValue.isEmpty {
                                viewModel.queriedUsers = try await SupabaseManager.shared.getUsersByQuery(value: newValue)
                            } else {
                                viewModel.queriedUsers = []
                            }
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
                if let queriedUsers = viewModel.queriedUsers,
                   !queriedUsers.isEmpty {
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
                } else {
                    Color.clear
                }
            }
            .navigationTitle("Select people \(!selectedUsers.isEmpty ? "(\(selectedUsers.count))" : "")")
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
                        selectedUsers.removeAll()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SelectUsersView(selectedUsers: .constant([]))
}
