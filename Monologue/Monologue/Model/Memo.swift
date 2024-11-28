//
//  Memo.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

struct Memo: Codable, Equatable, Identifiable {
    var id: String = UUID().uuidString
    var content: String // 메모 내용
    var email: String  // 유저 이메일
    var userNickname: String // 유저 닉네임
    var font: String // 글꼴
    var backgroundImageName: String // 배경 사진명
    var categories: [String] // 카테고리
    var likes: [String] // 좋아요 개수
    var date: Date // 날짜
    var lineCount: Int // 라인 수
    
    var comments: [Comment]? // 댓글
    
    static func == (lhs: Memo, rhs: Memo) -> Bool {
        return lhs.id == rhs.id &&
        lhs.content == rhs.content &&
        lhs.email == rhs.email &&
        lhs.userNickname == rhs.userNickname &&
        lhs.font == rhs.font &&
        lhs.backgroundImageName == rhs.backgroundImageName &&
        lhs.categories == rhs.categories &&
        lhs.likes == rhs.likes &&
        lhs.date == rhs.date &&
        lhs.lineCount == rhs.lineCount
//        lhs.comments == rhs.comments
    }
    
    init(document: QueryDocumentSnapshot) async throws {
        let docData = document.data()
        
        self.id = document.documentID
        self.content = docData["content"] as? String ?? ""
        self.email = docData["email"] as? String ?? ""
        self.userNickname = docData["userNickname"] as? String ?? ""
        self.font = docData["font"] as? String ?? ""
        self.backgroundImageName = docData["backgroundImageName"] as? String ?? ""
        self.categories = docData["categories"] as? [String] ?? []
        self.likes = docData["likes"] as? [String] ?? []
        self.lineCount = docData["lineCount"] as? Int ?? 0
        
        if let timestamp = docData["date"] as? Timestamp {
            self.date = timestamp.dateValue()
        } else {
            self.date = Date()
        }
        
        self.comments = try await fetchComments(for: document)
    }
    
    init(content: String, email: String, userNickname: String, font: String, backgroundImageName: String, categories: [String], likes: [String], date: Date, lineCount: Int, comments: [Comment]) {
        self.content = content
        self.email = email
        self.userNickname = userNickname
        self.font = font
        self.backgroundImageName = backgroundImageName
        self.categories = categories
        self.likes = likes
        self.date = date
        self.lineCount = lineCount
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
