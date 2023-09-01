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
    
    /*func uploadImage(image: UIImage, user: UserInfo) async throws -> URL? {
        let storageRef = storage.reference()
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        let data = image.compressJpeg(size: 200, quality: 0.2)
        var imageUrl: URL? = nil
        
        
        let uploadTask = imageRef.putData(data, metadata: metadata) { metadata, error in
            imageRef.downloadURL { url, error in
                guard let url = url else { return }
                imageUrl = url
                print("download url \(url)")
            }
        }
        
        print("return url \(imageUrl)")
        return imageUrl
    }*/
    
    func getImage(from storageURL: URL, completion: @escaping (UIImage?) -> Void) throws {
        let storageRef = try storage.reference(for: storageURL)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let data = data {
                completion(UIImage(data: data))
            } else if let error = error {
                completion(nil)
                print(error)
            }
        }
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
    
    func upload(to folder: String, completion: @escaping (URL?) -> Void) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child(folder)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        let data = self.compressJpeg(size: 200, quality: 0.2)
        guard let data else {
            completion(nil)
            return
        }
        
        imageRef.putData(data, metadata: metadata) { metadata, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    print(error)
                    completion(nil)
                } else {
                    completion(url)
                }
            }
        }
    }
}
