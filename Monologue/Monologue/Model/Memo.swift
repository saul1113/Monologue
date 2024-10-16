//
//  Memo.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Memo: Codable, Identifiable {
    var id: String = UUID().uuidString
    var content: String // 메모 내용
    var userNickname: String // 유저 닉네임
    var font: String // 글꼴
    var backgroundImageName: String // 배경 사진명
    var categories: [String] // 카테고리
    var likes: [String] // 좋아요 개수
    var comments: [String] // 코멘트ID
    var date: Date // 날짜
    var lineCount: Int //라인 수
    
    init(document: QueryDocumentSnapshot) {
        let docData = document.data()
        
        self.id = document.documentID
        self.content = docData["content"] as? String ?? ""
        self.userNickname = docData["userNickname"] as? String ?? ""
        self.font = docData["font"] as? String ?? ""
        self.backgroundImageName = docData["backgroundImageName"] as? String ?? ""
        self.categories = docData["categories"] as? [String] ?? []
        self.likes = docData["likes"] as? [String] ?? []
        self.comments = docData["comments"] as? [String] ?? []
        self.lineCount = docData["lineCount"] as? Int ?? 0
        
        if let timestamp = docData["date"] as? Timestamp {
            self.date = timestamp.dateValue()
        } else {
            self.date = Date()
        }
    }
    
    init(content: String, userNickname: String, font: String, backgroundImageName: String, categories: [String], likes: [String], comments: [String], date: Date, lineCount: Int) {
        self.content = content
        self.userNickname = userNickname
        self.font = font
        self.backgroundImageName = backgroundImageName
        self.categories = categories
        self.likes = likes
        self.comments = comments
        self.date = date
        self.lineCount = lineCount
    }
}
