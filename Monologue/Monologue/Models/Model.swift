//
//  Model.swift
//  Monologue
//
//  Created by 홍지수 on 10/15/24.
//

import SwiftUI

// User 모델
struct UserInfo: Codable {
    var nickname: String
    var preferredCategories: [String]
    var profileImageName: String
    var introduction: String
    var following: [String]
    var followers: [String]
    var blocked: [String]
    var likes: [String]
}

// Memo 모델
struct Memo: Codable, Identifiable {
    var id: String = UUID().uuidString
    var content: String
    var userNickname: String
    var font: String
    var backgroundImageName: String
    var categories: [String]
    var likes: [String]
    var comments: [String]
    var date: Date
}

// Column 모델
struct Column: Codable, Identifiable {
    var id: String = UUID().uuidString
    var content: String
    var userNickname: String
    var categories: [String]
    var likes: [String]
    var comments: [String]
    var date: Date
}

// Comment 모델
struct Comment: Codable, Identifiable {
    var id: String = UUID().uuidString
    var content: String
    var date: Date
}

// Complain 모델
struct Complain: Codable {
    var reportedID: String
    var userNickname: String
    var reason: Int
    var date: Date
}
