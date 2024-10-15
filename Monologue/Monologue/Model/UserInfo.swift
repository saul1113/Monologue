//
//  UserInfo.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation

struct UserInfo: Codable {
    var nickname: String // 닉네임
    var preferredCategories: [String] // 선호 카테고리
    var profileImageName: String // 프로필 사진명
    var introduction: String // 자기소개
    var following: [String] // 팔로잉 목록
    var followers: [String] // 팔로워 목록
    var blocked: [String] // 차단 목록
    var likes: [String] // 좋아요 목록
}
