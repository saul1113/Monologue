//
//  Column.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Column: Codable, Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var content: String // 칼럼 내용
    var userNickname: String // 유저 닉네임
    var categories: [String] // 카테고리
    var likes: [String] // 좋아요 개수
    var comments: [String] // 코멘트 ID
    var date: Date // 날짜
    
    init(document: QueryDocumentSnapshot) {
        let docData = document.data()
        
        self.id = document.documentID
        self.title = docData["title"] as? String ?? ""
        self.content = docData["content"] as? String ?? ""
        self.userNickname = docData["userNickname"] as? String ?? ""
        self.categories = docData["categories"] as? [String] ?? []
        self.likes = docData["likes"] as? [String] ?? []
        self.comments = docData["comments"] as? [String] ?? []
        
        if let timestamp = docData["date"] as? Timestamp {
            self.date = timestamp.dateValue()
        } else {
            self.date = Date()
        }
    }
    
    init(title: String, content: String, userNickname: String, font: String, backgroundImageName: String, categories: [String], likes: [String], comments: [String], date: Date) {
        self.title = title
        self.content = content
        self.userNickname = userNickname
        self.categories = categories
        self.likes = likes
        self.comments = comments
        self.date = date
    }
}
