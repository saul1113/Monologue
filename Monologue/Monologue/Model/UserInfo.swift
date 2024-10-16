//
//  UserInfo.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct UserInfo: Codable, Hashable {
    var nickname: String // 닉네임
    var registrationDate: Date  // 가입날짜
    var preferredCategories: [String] // 선호 카테고리
    var profileImageName: String // 프로필 사진명
    var introduction: String // 자기소개
    var followings: [String] // 팔로잉 목록
    var followers: [String] // 팔로워 목록
    var blocked: [String] // 차단 목록
    var likes: [String] // 좋아요 목록
    
    // 가입 날짜 Formatter 생성
    var formattedRegistration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 HH시 mm분"
        return formatter.string(from: registrationDate)
    }
    
    init(document: QueryDocumentSnapshot) {
        let docData = document.data()
        
        self.nickname = docData["nickname"] as? String ?? ""
        self.preferredCategories = docData["preferredCategories"] as? [String] ?? []
        self.profileImageName = docData["profileImageName"] as? String ?? ""
        self.introduction = docData["introduction"] as? String ?? ""
        self.followers = docData["followers"] as? [String] ?? []
        self.followings = docData["followings"] as? [String] ?? []
        self.blocked = docData["blocked"] as? [String] ?? []
        self.likes = docData["likes"] as? [String] ?? []
        
        if let timestamp = docData["date"] as? Timestamp {
            self.registrationDate = timestamp.dateValue()
        } else {
            self.registrationDate = Date()
        }
    }
    
    init(nickname: String, registrationDate: Date, preferredCategories: [String], profileImageName: String, introduction: String, followers: [String], followings: [String], blocked: [String], likes: [String]) {
        self.nickname = nickname
        self.preferredCategories = preferredCategories
        self.profileImageName = profileImageName
        self.introduction = introduction
        self.followers = followers
        self.followings = followings
        self.blocked = blocked
        self.likes = likes
        self.registrationDate = registrationDate
    }
}
