//
//  QueryUsersView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/29/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class QueryUsersViewModel: ObservableObject {
    private var disposeBag = Set<AnyCancellable>()
    
    @Published var query: String = ""
    @Published var debouncedQuery: String = ""
    @Published var queriedUsers: [UserInfo] = []
    
    init() {
        self.debounceTextChanges()
    }
    
    private func debounceTextChanges() {
        $query
        // 1 second debounce
            .debounce(for: 1, scheduler: RunLoop.main)
        // Called when user stops typing for 1 second
            .sink {
                self.debouncedQuery = $0
            }
            .store(in: &disposeBag)
    }
}

struct QueryUsersView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = QueryUsersViewModel()
    
    @State private var showCancel: Bool = false
    @FocusState private var focusedInput: FocusableField?
    private enum FocusableField: Hashable {
        case searchBar
    }
    
    var body: some View {
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
                            viewModel.queriedUsers = try await UserManager.shared.getUsers(matching: newValue)
                        } else {
                            viewModel.queriedUsers = []
                        }
                    }
                }
                .onChange(of: focusedInput) { input in
                    withAnimation(.spring(duration: 0.25)) {
                        if input == .searchBar {
                            showCancel = true
                        } else {
                            showCancel = false
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
                if showCancel {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 17))
                            .tint(.secondary)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            if !viewModel.queriedUsers.isEmpty {
                List {
                    ForEach(viewModel.queriedUsers) { user in
                        NavigationLink {
                            ProfileView(user: user)
                        } label: {
                            Text(user.displayName ?? "Unknown user")
                        }
                        
                    }
                }
                .listStyle(.inset)
            } else {
                Color.clear
            }
        }
        .onAppear {
            focusedInput = .searchBar
        }
    }
}

#Preview {
    NavigationStack {
        QueryUsersView()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        
                    }
                }
            }
    }
    
}
