//
//  SupabaseManager.swift
//  Celery
//
//  Created by Skylar Clemens on 9/19/23.
//

import Foundation
import Supabase
import UIKit

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    init() {
        let SUPABASE_URL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        let SUPABASE_API_KEY = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_API_KEY") as? String ?? ""
        
        self.client = SupabaseClient(supabaseURL: URL(fileURLWithPath: SUPABASE_URL), supabaseKey: SUPABASE_API_KEY)
    }
    
    // Retrieve user's avatar image from Supabase storage
    func getAvatarImage(imagePath: String, type: UserPhotoType = .user, completion: @escaping (UIImage?) -> Void) async throws {
        do {
            let storageRef = try await self.client.storage
                .from(id: type.rawValue)
                .download(path: imagePath)
            completion(UIImage(data: storageRef))
        } catch {
            completion(nil)
            print(error)
        }
    }
    
    func uploadImageToStorage(_ image: UIImage, to folder: String, name pathName: String) async throws {
        let data = image.compressJpeg(size: 200, quality: 0.2)
        guard let data else {
            throw "Error retrieving data"
        }
        
        let imageFile = File(name: pathName, data: data, fileName: "\(pathName).jpg", contentType: "jpg")
        
        do {
            let image = try await self.client.storage.from(id: folder).upload(
                path: pathName,
                file: imageFile,
                fileOptions: FileOptions(cacheControl: "604800"))
        } catch {
            print(error)
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
