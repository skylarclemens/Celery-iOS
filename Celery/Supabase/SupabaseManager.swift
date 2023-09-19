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
        print(SUPABASE_URL)
        print(SUPABASE_API_KEY)
        
        self.client = SupabaseClient(supabaseURL: URL(fileURLWithPath: SUPABASE_URL), supabaseKey: SUPABASE_API_KEY)
    }
    
    func getAvatarImage(imagePath: String, completion: @escaping (UIImage?) -> Void) async throws {
        do {
            let storageRef = try await SupabaseManager.shared.client.storage
                .from(id: "avatars")
                .download(path: imagePath)
            completion(UIImage(data: storageRef))
        } catch {
            completion(nil)
            print(error)
        }
    }
}
