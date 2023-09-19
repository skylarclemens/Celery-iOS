//
//  StorageManager.swift
//  Celery
//
//  Created by Skylar Clemens on 8/31/23.
//

import Foundation
import SwiftUI

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
        /*let storageRef = Storage.storage().reference()
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
        }*/
    }
}
