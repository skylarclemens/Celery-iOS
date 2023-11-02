//
//  SelectUserRowView.swift
//  Celery
//
//  Created by Skylar Clemens on 11/1/23.
//

import SwiftUI

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

