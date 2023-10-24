//
//  AvatarUploadView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/31/23.
//

import SwiftUI
import PhotosUI

enum ImageState: Equatable {
    case empty
    case loading
    case success
    case failure
}

struct AvatarUploadView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil
    @State private var imageState: ImageState = .empty
    @Binding var avatarUrl: String
    var type: UserPhotoType = .user
    
    var size: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: imageState == .empty ? .bottom : .center) {
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
            } else if imageState == .empty {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.75))
                    .foregroundStyle(.black.opacity(0.25))
                    .offset(y: size/16)
            }
            Circle()
                .strokeBorder(.white, lineWidth: 3)
        }
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(alignment: .bottomTrailing) {
            PhotosPicker(selection: $selectedImage,
                         matching: .images,
                         photoLibrary: .shared()) {
                Image(systemName: "pencil.circle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: size/3.5))
                    .foregroundStyle(Color(UIColor.systemGray2))
                    .overlay(
                        Circle()
                            .stroke(.background, lineWidth: 2)
                            .frame(width: size/3.5)
                    )
            }
        }.onChange(of: selectedImage) { _ in
            Task {
                self.imageState = .loading
                do {
                    let data = try await selectedImage?.loadTransferable(type: Data.self)
                    if let data,
                       let currentUser = authViewModel.currentUser,
                       let uiImage = UIImage(data: data) {
                        let path = "\(currentUser.id.uuidString)/\(UUID().uuidString)"
                        try await SupabaseManager.shared.uploadImageToStorage(uiImage, to: type.rawValue, name: path)
                        self.avatarImage = uiImage
                        self.imageState = .success
                        self.avatarUrl = path
                    }
                } catch {
                    self.imageState = .failure
                }
            }
        }
        .task {
            if !avatarUrl.isEmpty {
                self.imageState = .loading
                try? await SupabaseManager.shared.getAvatarImage(imagePath: avatarUrl, type: type) { image in
                    if let image {
                        self.avatarImage = image
                        self.imageState = .success
                    } else {
                        self.imageState = .empty
                    }
                }
            } else {
                self.imageState = .empty
            }
        }
    }
}

#Preview {
    AvatarUploadView(avatarUrl: .constant(""))
}
