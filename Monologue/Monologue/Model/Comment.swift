//
//  Comment.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Comment: Codable, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var userNickname: String // 작성자
    var content: String // 코멘트 내용
    var date: Date // 날짜
    
    init(document: QueryDocumentSnapshot) {
        let docData = document.data()
        
        self.id = document.documentID
        self.userNickname = docData["userNickname"] as? String ?? ""
        self.content = docData["content"] as? String ?? ""
        if let timestamp = docData["date"] as? Timestamp {
            self.date = timestamp.dateValue()
        } else {
            self.date = Date()
        }
    }
    
    init(userNickname: String, content: String, date: Date) {
        self.userNickname = userNickname
        self.content = content
        self.date = date
    }
}

