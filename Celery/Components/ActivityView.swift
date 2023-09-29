//
//  ActivityView.swift
//  Celery
//
//  Created by Skylar Clemens on 9/28/23.
//

import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    let activity: Activity?
    @State private var user: UserInfo?
    @State private var currentUser: UserInfo?
    @State var relatedExpense: Expense? = nil
    @State var relatedDebt: Debt? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let user {
                    UserPhotoView(size: 35, imagePath: user.avatar_url)
                    Text(user.name ?? "Unknown user")
                        .fontWeight(.semibold) +
                    Text(" \(activity?.action?.getAssociatedString() ?? "unknown activity")") +
                    Text(" \(activity?.type?.rawValue.lowercased() ?? "")")
                }
            }
            .font(.system(size: 14))
            .padding(2)
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 40)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
            if let activityDate = activity?.created_at {
                Group {
                    Text(activityDate, style: .date)
                        .fontWeight(.medium) +
                    Text(", ") +
                    Text(activityDate, style: .time)
                }
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .offset(x: 46)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            if let activity,
               let userId = activity.user_id {
                self.user = try? await SupabaseManager.shared.getUser(userId: userId)
            }
        }
    }
}

#Preview {
    ActivityView(activity: Activity(id: 387, user_id: UUID(uuidString: "b1133fd5-7840-4a18-bfb3-18439bfee95e"), reference_id: UUID(uuidString: "cf97c672-9c31-47bb-b27f-aa79d3627376"), type: .expense, action: .create, created_at: Date()))
}

extension ActivityAction {
    func getAssociatedString() -> String {
        switch self {
        case .create: return "created a new"
        case .update: return "updated the"
        case .delete: return "deleted the"
        case .pay: return "paid"
        }
    }
}
