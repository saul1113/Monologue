//
//  CommentStore.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation
import Observation
import FirebaseCore
import FirebaseFirestore

class CommentStore: ObservableObject {
    @Published var comments: [Comment] = []
        
    // MARK: - 댓글 전체 추가, 수정
    func addComment(comment: Comment, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Comment").document(comment.id).setData([
            "userNickname": comment.userNickname,
            "content": comment.content,
            "date": Timestamp(date: comment.date)
        ]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - 댓글 전체 로드
    func loadComments(completion: @escaping ([Comment]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Comment").getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var comments: [Comment] = []
                
                for document in querySnapshot!.documents {
                    let comment = Comment(document: document)
                    
                    comments.append(comment)
                }
                completion(comments, nil)
            }
    }
    
    // MARK: - 댓글 유저 닉네임으로 로드
    func loadCommentsByUserNickname(userNickname: String, completion: @escaping ([Comment]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Comment")
            .whereField("userNickname", isEqualTo: userNickname)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var comments: [Comment] = []
                
                for document in querySnapshot!.documents {
                    let comment = Comment(document: document)
                    
                    comments.append(comment)
                }
                completion(comments, nil)
            }
    }
    
    // MARK: - 댓글 ID들로 로드
    func fetchCommentsByDocumentIDs(commentIDs: [String], completion: @escaping ([Comment]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("comments")
            .whereField(FieldPath.documentID(), in: commentIDs) // documentID로 쿼리
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var comments: [Comment] = []
                
                // 각 문서를 Comment 객체로 변환
                for document in querySnapshot!.documents {
                    let comment = Comment(document: document)
                    
                    comments.append(comment)
                    
                }
                
                // 조회된 코멘트 배열을 completion 핸들러로 반환
                completion(comments, nil)
            }
    }
    
    // MARK: - 댓글 아이디로 메모 삭제
    func deleteComment(commentId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Comment").document(commentId).delete { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Test
    func deleteComment(columnId: String, commentId: String) async throws {
        let db = Firestore.firestore()
        let commentRef = db.collection("Column").document(columnId).collection("comments").document(commentId)
        
        do {
            try await commentRef.delete()            
        } catch {
            print("deleteComment error: \(error.localizedDescription)")
        }
    }

    func addComment(columnId: String, comment: Comment) async throws {
        let db = Firestore.firestore()
        let columnRef = db.collection("Column").document(columnId)
        let commentRef = columnRef.collection("comments").document(comment.id)
        
        do {
            try await commentRef.setData([
                "content": comment.content,
                "date": comment.date,
                "userNickname": comment.userNickname
            ])
        } catch {
            print("addComment error: \(error.localizedDescription)")
        }
    }
    
    func deleteComment(memoId: String, commentId: String) async throws {
        let db = Firestore.firestore()
        let commentRef = db.collection("Memo").document(memoId).collection("comments").document(commentId)
        
        do {
            try await commentRef.delete()
        } catch {
            print("deleteComment error: \(error.localizedDescription)")
        }
    }

    func addComment(memoId: String, comment: Comment) async throws {
        let db = Firestore.firestore()
        let columnRef = db.collection("Memo").document(memoId)
        let commentRef = columnRef.collection("comments").document(comment.id)
        
        do {
            try await commentRef.setData([
                "content": comment.content,
                "date": comment.date,
                "userNickname": comment.userNickname
            ])
        } catch {
            print("addComment error: \(error.localizedDescription)")
        }
    }
}
