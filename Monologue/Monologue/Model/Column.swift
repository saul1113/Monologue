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
    var email: String // 유저 이메일
    var userNickname: String // 유저 닉네임
    var categories: [String] // 카테고리
    var likes: [String] // 좋아요 개수
    var date: Date // 날짜
    
    var comments: [Comment]? // 댓글
    
    init(id: String, title: String, content: String, email: String, userNickname: String, categories: [String], likes: [String], date: Date, comments: [Comment]?) {
        self.id = id // Set the existing id when editing
        self.title = title
        self.content = content
        self.email = email
        self.userNickname = userNickname
        self.categories = categories
        self.likes = likes
        self.date = date
        self.comments = comments
    }
    
    init(document: QueryDocumentSnapshot) async throws {
        let docData = document.data()
        
        self.id = document.documentID
        self.title = docData["title"] as? String ?? ""
        self.content = docData["content"] as? String ?? ""
        self.email = docData["email"] as? String ?? ""
        self.userNickname = docData["userNickname"] as? String ?? ""
        self.categories = docData["categories"] as? [String] ?? []
        self.likes = docData["likes"] as? [String] ?? []
        
        if let timestamp = docData["date"] as? Timestamp {
            self.date = timestamp.dateValue()
        } else {
            self.date = Date()
        }
        
        self.comments = try await fetchComments(for: document)
    }
    
    init(title: String, content: String, email: String, userNickname: String, categories: [String], likes: [String], date: Date, comments: [Comment]) {
        self.title = title
        self.content = content
        self.email = email
        self.userNickname = userNickname
        self.categories = categories
        self.likes = likes
        self.date = date
        self.comments = comments
    }
    
    private func fetchComments(for document: QueryDocumentSnapshot) async throws -> [Comment] {
        let commentsRef = document.reference.collection("comments")
        let querySnapshot = try await commentsRef.getDocuments()
        
        var fetchedComments: [Comment] = []
        for commentDoc in querySnapshot.documents {
            let comment = Comment(document: commentDoc)
            fetchedComments.append(comment)
        }
        
        return fetchedComments
    }
}
