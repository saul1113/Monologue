//
//  UserInfoStore.swift
//  Monologue
//
//  Created by 김종혁 on 10/15/24.
//

import Foundation
import Observation
import FirebaseCore
import FirebaseFirestore
import SwiftUICore

@MainActor
class UserInfoStore: ObservableObject {
    
    func addUserInfo(_ user: UserInfo, email: String) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(email).collection("UserInfo").document(user.formattedRegistration).setData([
                "nickname": user.nickname,
                "registrationDate": Timestamp(date: user.registrationDate),
                "preferredCategories": user.preferredCategories,
                "profileImageName": user.profileImageName,
                "introduction": user.introduction,
                "following": user.following,
                "followers": user.followers,
                "blocked": user.blocked,
                "likes": user.likes
            ])
            
            print("Document successfully written!")
        } catch {
            print("Error writing document: \(error)")
        }
    }
}
