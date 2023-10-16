//
//  ActivitySupabaseManager.swift
//  Celery
//
//  Created by Skylar Clemens on 10/16/23.
//

import Foundation

extension SupabaseManager {
    // Fetch activity
    func getActivity(id: Int) async throws -> Activity? {
        do {
            let fetchedActivity: [Activity] = try await self.client.database.from("activity")
                .select()
                .eq(column: "id", value: id)
                .execute()
                .value
            return fetchedActivity.first
        } catch {
            print("Error fetching activity: \(error)")
            return nil
        }
    }
    
    // Add new activity to database
    func addNewActivity(activity: Activity) async throws {
        do {
            try await self.client.database.from("activity")
                .insert(values: activity)
                .execute()
        } catch {
            print("Error creating new activity: \(error)")
        }
    }
    
    func getRelatedActivities(for referenceId: UUID?) async throws -> [Activity]? {
        guard let referenceId else { return nil }
        do {
            let fetchedActivities: [Activity] = try await self.client.database.from("activity")
                .select()
                .eq(column: "reference_id", value: referenceId)
                .execute()
                .value
            return fetchedActivities
        } catch {
            print("Error fetching related activities: \(error)")
            return nil
        }
    }
}
