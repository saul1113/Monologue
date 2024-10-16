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
    private var memoStore: MemoStore = .init()
    private var columnStore: ColumnStore = .init()
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
                "followings": user.followings,
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
                "followings": user.followings,
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
            let following: [String] = docData["followings"] as? [String] ?? []
            let followers: [String] = docData["followers"] as? [String] ?? []
            let blocked: [String] = docData["blocked"] as? [String] ?? []
            let likes: [String] = docData["likes"] as? [String] ?? []
            
            // `userInfoStore` 업데이트
            self.userInfo = UserInfo(
                nickname: nickname,
                registrationDate: registrationDate,
                preferredCategories: preferredCategories,
                profileImageName: profileImageName,
                introduction: introduction,
                followers: following,
                followings: followers,
                blocked: blocked,
                likes: likes
            )
//            print("User info loaded successfully: \(String(describing: userInfo))")
            
        } catch {
            print("Error loading user info: \(error)")
        }
    }
    
    // 팔로워, 팔로잉, 차단 목록 로드
    func loadUsersInfoByEmail(emails: [String], completion: @escaping ([UserInfo]?, Error?) -> Void) {
        guard !emails.isEmpty else {
            completion([], nil) // 이메일 배열이 비어있으면 빈 배열을 반환
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("User")
            .whereField(FieldPath.documentID(), in: emails) // 배열로 변경
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var usersInfo: [UserInfo] = []
                
                for document in querySnapshot!.documents {
                    
                    let userInfo = UserInfo(document: document)
                    
                    usersInfo.append(userInfo)
                }
                
                completion(usersInfo, nil)
            }
    }
    
    // 메모 개수
    func getMemoCount(userNickname: String) -> Int {
        var count = 0
        
        memoStore.loadMemosByUserNickname(userNickname: userNickname) { memos, error in
            count = memos?.count ?? 0
        }
        
        return count
    }
    
    // 칼럼 개수
    
    func getColumnCount(userNickname: String) -> Int {
        var count = 0
        
        columnStore.loadColumnsByUserNickname(userNickname: userNickname) { columns, error in
            count = columns?.count ?? 0
        }
        
        return count
    }
}
