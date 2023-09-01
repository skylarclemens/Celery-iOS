//
//  StorageManager.swift
//  Celery
//
//  Created by Skylar Clemens on 8/31/23.
//

import Foundation
import SwiftUI
import FirebaseStorage

class FirebaseStorageManager: ObservableObject {
    let storage = Storage.storage()
    
    func uploadImage(image: UIImage, user: UserInfo) async throws -> URL? {
        let storageRef = storage.reference()
        let imageRef = storageRef.child("avatars/\(user.id).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        let data = image.compressJpeg(size: 200, quality: 0.2)
        var imageUrl: URL? = nil
        
        if let data {
            _ = try await imageRef.putDataAsync(data)
            imageRef.downloadURL { url, error in
                guard let url else { return }
                imageUrl = url
            }
        }
        return imageUrl
    }
    
    func getImage(from storageURL: URL) throws -> UIImage? {
        let storageRef = try storage.reference(for: storageURL)
        var returnImage: UIImage? = nil
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let data = data {
                returnImage = UIImage(data: data)
            } else if let error = error {
                print(error)
            }
        }
        return returnImage
    }
}

extension UIImage {
    func resizeByHeight(_ height: CGFloat) -> UIImage {
        let scale = height / self.size.height
        let width = self.size.width * scale
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func compressJpeg(size: CGFloat, quality: CGFloat) -> Data? {
        let imageToCompress = self.resizeByHeight(size)
        let compressedImageData = imageToCompress.jpegData(compressionQuality: quality)
        
        return compressedImageData
    }
}
