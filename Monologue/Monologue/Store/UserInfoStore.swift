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
    @Published var userInfo: UserInfo? = nil
    
    // 로그인 시 사용자(닉네임, 가입날짜) 파베에 추가
    func addUserInfo(_ user: UserInfo, email: String) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(email).setData([
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
    
    // 사용자 정보 업데이트 (registrationDate는 업데이트되지 않음)
    func updateUserInfo(_ user: UserInfo, email: String) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(email).setData([
                "nickname": user.nickname,
                "preferredCategories": user.preferredCategories,
                "profileImageName": user.profileImageName,
                "introduction": user.introduction,
                "following": user.following,
                "followers": user.followers,
                "blocked": user.blocked,
                "likes": user.likes
            ])
            
            print("Document successfully updated!")
        } catch {
            print("Error updating document: \(error)")
        }
    }
    
    // 로드하는 부분
    func loadUserInfo(email: String) async {
        do {
            let db = Firestore.firestore()
            let document = try await db.collection("User").document(email).getDocument()
            
            guard let docData = document.data() else {
                print("No user data found for email: \(email)")
                return
            }
            
            let nickname: String = docData["nickname"] as? String ?? ""
            let registrationDate: Date = (docData["registrationDate"] as? Timestamp)?.dateValue() ?? Date()
            let preferredCategories: [String] = docData["preferredCategories"] as? [String] ?? []
            let profileImageName: String = docData["profileImageName"] as? String ?? ""
            let introduction: String = docData["introduction"] as? String ?? ""
            let following: [String] = docData["following"] as? [String] ?? []
            let followers: [String] = docData["followers"] as? [String] ?? []
            let blocked: [String] = docData["blocked"] as? [String] ?? []
            let likes: [String] = docData["likes"] as? [String] ?? []
            
            // `userInfo` 업데이트
            self.userInfo = UserInfo(
                nickname: nickname,
                registrationDate: registrationDate,
                preferredCategories: preferredCategories,
                profileImageName: profileImageName,
                introduction: introduction,
                following: following,
                followers: followers,
                blocked: blocked,
                likes: likes
            )
            print("User info loaded successfully: \(String(describing: userInfo))")
            
        } catch {
            print("Error loading user info: \(error)")
        }
    }
}
