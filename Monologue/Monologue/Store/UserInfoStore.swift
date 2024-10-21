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
    
    @Published var followers: [UserInfo] = []
    @Published var followings: [UserInfo] = []
    
    @Published var followersCount: Int = 0
    @Published var followingsCount: Int = 0
    
    @Published var memoCount: [String: Int] = [:] // 닉네임별 메모 개수 저장
    @Published var columnCount: [String: Int] = [:] // 닉네임별 칼럼 개수 저장
    
    private var listener: ListenerRegistration?
    
    // 로그인 시 사용자(닉네임, 가입날짜) 파베에 추가
    func addUserInfo(_ user: UserInfo) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(user.email).setData([
                "uid": user.uid,
                "nickname": user.nickname,
                "registrationDate": Timestamp(date: user.registrationDate),
                "preferredCategories": user.preferredCategories,
                "profileImageName": user.profileImageName,
                "introduction": user.introduction,
                "followings": user.followings,
                "followers": user.followers,
                "blocked": user.blocked,
                "likesMemos": user.likesMemos,
                "likesColumns": user.likesColumns
            ])
            
            print("Document successfully written!")
        } catch {
            print("Error writing document: \(error)")
        }
    }
    
    // 사용자 정보 업데이트 (registrationDate는 업데이트되지 않음)
    func updateUserInfo(_ user: UserInfo) async {
        do {
            let db = Firestore.firestore()
            
            try await db.collection("User").document(user.email).setData([
                "uid": user.uid,
                "nickname": user.nickname,
                "preferredCategories": user.preferredCategories,
                "profileImageName": user.profileImageName,
                "introduction": user.introduction,
                "followings": user.followings,
                "followers": user.followers,
                "blocked": user.blocked,
                "likesMemos": user.likesMemos,
                "likesColumns": user.likesColumns
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
            
            let uid: String = docData["uid"] as? String ?? ""
            let nickname: String = docData["nickname"] as? String ?? ""
            let registrationDate: Date = (docData["registrationDate"] as? Timestamp)?.dateValue() ?? Date()
            let preferredCategories: [String] = docData["preferredCategories"] as? [String] ?? []
            let profileImageName: String = docData["profileImageName"] as? String ?? ""
            let introduction: String = docData["introduction"] as? String ?? ""
            let followings: [String] = docData["followings"] as? [String] ?? []
            let followers: [String] = docData["followers"] as? [String] ?? []
            let blocked: [String] = docData["blocked"] as? [String] ?? []
            let likesMemos: [String] = docData["likesMemos"] as? [String] ?? []
            let likesColumns: [String] = docData["likesColumns"] as? [String] ?? []
            
            // `userInfoStore` 업데이트
            self.userInfo = UserInfo(
                uid: uid,
                email: email,
                nickname: nickname,
                registrationDate: registrationDate,
                preferredCategories: preferredCategories,
                profileImageName: profileImageName,
                introduction: introduction,
                followers: followers,
                followings: followings,
                blocked: blocked,
                likesMemos: likesMemos,
                likesColumns: likesColumns
            )
            //            print("User info loaded successfully: \(String(describing: userInfo))")
            
        } catch {
            print("Error loading user info: \(error)")
        }
    }
    
    // 이메일에 따른 유저들의 정보를 배열로 불러오는 함수(유저 목록에 사용)
    func loadUsersInfoByEmail(emails: [String]) async throws -> [UserInfo] {
        guard !emails.isEmpty else {
            return []
        }
        
        let db = Firestore.firestore()
        
        let querySnapshot = try await db.collection("User")
            .whereField(FieldPath.documentID(), in: emails) // 배열로 변경
            .getDocuments()
        
        var usersInfo: [UserInfo] = []
        
        for document in querySnapshot.documents {
            let userInfo = UserInfo(document: document)
            usersInfo.append(userInfo)
        }
        
        return usersInfo
    }
    
    // 메모 개수
    func getMemoCount(email: String) async throws -> Int {
        let memos = try await memoStore.loadMemosByUserEmail(email: email)
        return memos.count
    }
    
    // 칼럼 개수
    func getColumnCount(email: String) async throws -> Int {
        let columns = try await columnStore.loadColumnsByUserEmail(email: email)
        return columns.count
    }
    
    // MARK: - Follow 관련 로직
    // 팔로우 로직
    func followUser(targetUserEmail: String) async {
        guard let currentUserEmail = userInfo?.email, !currentUserEmail.isEmpty else {
            print("Current user email is empty.")
            return
        }
        guard !targetUserEmail.isEmpty else {
            print("Target user email is empty.")
            return
        }
        
        let db = Firestore.firestore()
        let currentUserRef = db.collection("User").document(currentUserEmail)
        let targetUserRef = db.collection("User").document(targetUserEmail)
        
        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                // 현재 유저의 followings에 타겟 유저 추가
                transaction.updateData([
                    "followings": FieldValue.arrayUnion([targetUserEmail])
                ], forDocument: currentUserRef)
                
                // 타겟 유저의 followers에 현재 유저 추가
                transaction.updateData([
                    "followers": FieldValue.arrayUnion([currentUserEmail])
                ], forDocument: targetUserRef)
                
                return nil
            }
            
            print("Successfully followed \(targetUserEmail)")
        } catch {
            print("Error following user: \(error)")
        }
    }
    
    // 언팔로우 로직
    func unfollowUser(targetUserEmail: String) async {
        guard let currentUserEmail = userInfo?.email, !currentUserEmail.isEmpty else {
            print("Current user email is empty.")
            return
        }
        guard !targetUserEmail.isEmpty else {
            print("Target user email is empty.")
            return
        }
        
        let db = Firestore.firestore()
        let currentUserRef = db.collection("User").document(currentUserEmail)
        let targetUserRef = db.collection("User").document(targetUserEmail)
        
        do {
            _ = try await db.runTransaction { transaction, errorPointer in
                // 현재 유저의 followings에서 타겟 유저 제거
                transaction.updateData([
                    "followings": FieldValue.arrayRemove([targetUserEmail])
                ], forDocument: currentUserRef)
                
                // 타겟 유저의 followers에서 현재 유저 제거
                transaction.updateData([
                    "followers": FieldValue.arrayRemove([currentUserEmail])
                ], forDocument: targetUserRef)
                
                return nil
            }
            
            print("Successfully unfollowed \(targetUserEmail)")
        } catch {
            print("Error unfollowing user: \(error)")
        }
    }
    
    // 특정 유저를 팔로우하고 있는지 확인
    func checkIfFollowing(targetUserEmail: String) async -> Bool {
        guard let currentUserEmail = userInfo?.email else {
            return false
        }
        
        let db = Firestore.firestore()
        let document = try? await db.collection("User").document(currentUserEmail).getDocument()
        
        if let data = document?.data(), let followings = data["followings"] as? [String] {
            return followings.contains(targetUserEmail)
        } else {
            return false
        }
    }
    
    // 특정 유저의 팔로우 실시간 감지
    func observeUserFollowData(email: String) {
        let db = Firestore.firestore()
        let userDocRef = db.collection("User").document(email)
        
        listener = userDocRef.addSnapshotListener { snapshot, error in
            guard let document = snapshot, document.exists else {
                print("User document does not exist")
                return
            }
            
            guard let docData = document.data() else {
                print("No user data found")
                return
            }
            
            if let followings = docData["followings"] as? [String] {
                self.followingsCount = followings.count
                print("Followings: \(followings)")
            }
            
            if let followers = docData["followers"] as? [String] {
                self.followersCount = followers.count
                print("Followers: \(followers)")
            }
        }
    }
    
    func removeListener() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - Block 관련 로직
    // 차단
    func blockUser(blockedEmail: String) async throws {
        guard let currentUserEmail = userInfo?.email else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("User").document(currentUserEmail)
        
        _ = try await db.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                let userSnapshot = try transaction.getDocument(userRef)
                guard let userData = userSnapshot.data() else { return nil }
                
                var blocked = userData["blocked"] as? [String] ?? []
                var followings = userData["followings"] as? [String] ?? []
                var followers = userData["followers"] as? [String] ?? []
                
                // 이미 차단된 유저가 아닌지 확인(중복 차단 방지)
                if !blocked.contains(blockedEmail) {
                    followings.removeAll { $0 == blockedEmail }
                    followers.removeAll { $0 == blockedEmail }
                    
                    blocked.append(blockedEmail)
                    
                    transaction.updateData([
                        "blocked": blocked,
                        "followings": followings,
                        "followers": followers
                    ], forDocument: userRef)
                }
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
        print("차단 성공")
    }
    
    // 차단 해제
    func unblockUser(blockedEmail: String) async throws {
        guard let currentUserEmail = userInfo?.email else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("User").document(currentUserEmail)
        
        _ = try await db.runTransaction { (transaction, errorPointer) -> Any? in
            do {
                // 현재 유저 정보 가져오기
                let userSnapshot = try transaction.getDocument(userRef)
                guard let userData = userSnapshot.data() else { return nil }
                
                // 기존 blocked 데이터 가져오기
                var blocked = userData["blocked"] as? [String] ?? []
                
                // 차단 해제할 유저가 blocked에 있는지 확인 후 제거
                if blocked.contains(blockedEmail) {
                    blocked.removeAll { $0 == blockedEmail }
                    
                    // Firestore에 업데이트
                    transaction.updateData([
                        "blocked": blocked
                    ], forDocument: userRef)
                }
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            return nil
        }
        print("차단 해제 성공")
    }
}
