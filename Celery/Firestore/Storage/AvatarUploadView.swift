//
//  AvatarUploadView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/31/23.
//

import SwiftUI
import PhotosUI
import FirebaseStorage

@MainActor

struct AvatarUploadView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    private var storageManager = FirebaseStorageManager()
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil
    @State private var avatarUrl: URL? = nil
    @State private var imageState: ImageState = .empty
    
    private enum ImageState: Equatable {
        case empty
        case loading
        case success
        case failure
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.black.opacity(0.1))
            if imageState == .success,
               let avatarImage {
                Image(uiImage: avatarImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } else if imageState == .loading {
                ProgressView()
                     .progressViewStyle(.circular)
            }
            Circle()
                .strokeBorder(.white, lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .frame(width: 100, height: 100)
        .overlay(alignment: .bottomTrailing) {
            PhotosPicker(selection: $selectedImage,
                         matching: .images,
                         photoLibrary: .shared()) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 30))
                    .foregroundStyle(Color(red: 0.87, green: 0.88, blue: 0.89))
            }
        }.onChange(of: selectedImage) { _ in
            Task {
                self.imageState = .loading
                do {
                    let data = try? await selectedImage?.loadTransferable(type: Data.self)
                    if let data,
                       let uiImage = UIImage(data: data),
                       let currentUser = authViewModel.currentUserInfo {
                        self.avatarImage = uiImage
                        self.avatarUrl = try await storageManager.uploadImage(image: uiImage, user: currentUser)
                        try await authViewModel.updateCurrentUsersProfilePhoto(imageUrl: avatarUrl)
                        self.imageState = .success
                    }
                } catch {
                    self.imageState = .failure
                }
            }
        }.onAppear {
            if let photoURL = authViewModel.currentUser?.photoURL,
               let userAvatar = try? storageManager.getImage(from: photoURL) {
                self.avatarImage = userAvatar
            }
        }
    }
}

#Preview {
    AvatarUploadView()
}
