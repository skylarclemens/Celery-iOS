//
//  UserPhotoView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/31/23.
//

import SwiftUI

struct UserPhotoView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var imageState: ImageState = .empty
    @State var userPhoto: UIImage? = nil
    
    let size: CGFloat
    var borderSize: CGFloat = 3
    
    @State var imagePath: String? = nil
    
    var body: some View {
        ZStack(alignment: imageState == .empty ? .bottom : .center) {
            Circle()
                .fill(Color(red: 0.87, green: 0.88, blue: 0.89))
            if imageState == .success,
               let userPhoto {
                Image(uiImage: userPhoto)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if imageState == .loading {
                ProgressView()
                     .progressViewStyle(.circular)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.75))
                    .foregroundStyle(.black.opacity(0.25))
                    .offset(y: size/16)
            }
        }
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .inset(by: -borderSize+(borderSize/2))
                .stroke(Color(uiColor: UIColor.secondarySystemGroupedBackground), lineWidth: borderSize)
        )
        .task {
            if let imagePath {
                self.imageState = .loading
                try? await SupabaseManager.shared.getAvatarImage(imagePath: imagePath) { image in
                    if let image {
                        self.userPhoto = image
                        self.imageState = .success
                    } else {
                        self.imageState = .empty
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Rectangle()
            .fill(.gray)
        VStack {
            UserPhotoView(size: 40)
            UserPhotoView(size: 50)
        }
    }
}
