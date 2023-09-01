//
//  UserPhotoView.swift
//  Celery
//
//  Created by Skylar Clemens on 8/31/23.
//

import SwiftUI

struct UserPhotoView: View {
    private let storageManager = FirebaseStorageManager()
    
    @State var imageState: ImageState = .empty
    @State var userPhoto: UIImage? = nil
    
    let size: CGFloat
    @State var photoURL: URL? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
                    .offset(y: 2)
                    .clipShape(Circle())
            }
            Circle()
                .stroke(.white, lineWidth: 12)
        }
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .frame(width: size, height: size)
        .clipShape(Circle())
        .onAppear {
            if let photoURL {
                self.imageState = .loading
                try? storageManager.getImage(from: photoURL) { image in
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
    UserPhotoView(size: 80)
}
