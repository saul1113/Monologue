//
//  ColumnStore.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation
import Observation
import FirebaseCore
import FirebaseFirestore

class ColumnStore: ObservableObject {
    @Published var columns: [Column] = []
        
    // MARK: - 칼럼 전체 추가, 수정
    func addColumn(column: Column, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Column").document(column.id).setData([
            "content": column.content,
            "userNickname": column.userNickname,
            "categories": column.categories,
            "likes": column.likes,
            "comments": column.comments,
            "date": Timestamp(date: column.date)
        ]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - 칼럼 전체 로드
    func loadColumn(completion: @escaping ([Column]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Column").getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var columns: [Column] = []
                
                for document in querySnapshot!.documents {
                    let column = Column(document: document)
                    
                    columns.append(column)
                }
                completion(columns, nil)
            }
    }
    
    // MARK: - 칼럼 유저 닉네임으로 로드
    func loadColumnsByUserNickname(userNickname: String, completion: @escaping ([Column]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Column")
            .whereField("userNickname", isEqualTo: userNickname)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var columns: [Column] = []
                
                for document in querySnapshot!.documents {
                    let column = Column(document: document)
                    
                    columns.append(column)
                }
                completion(columns, nil)
            }
    }
    
    // MARK: - 칼럼 카테고리들로 로드
    func loadColumnsByCategories(categories: [String], completion: @escaping ([Column]?, Error?) -> Void) {
        let db = Firestore.firestore()
            
            db.collection("Column")
            .whereField("categories", arrayContains: categories[0])
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    
                    var columns: [Column] = []
                    
                    for document in querySnapshot!.documents {
                        let column = Column(document: document)
                        
                        columns.append(column)
                    }
                    
                    completion(columns, nil)
                }
    }
    
    // MARK: - 칼럼 아이디로 메모 삭제
    func deleteColumn(columnId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Column").document(columnId).delete { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - 좋아요 수정
    func updateLikes(columnId: String, userNickname: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        loadColumnLikes(columnId: columnId) { likes, error in
            if let error = error {
                completion(error)
                return
            }
            
            var tempLikes: [String] = likes ?? []
            
            if tempLikes.contains(userNickname) {
                tempLikes.remove(at: tempLikes.firstIndex(of: userNickname)!)
            } else {
                tempLikes.append(userNickname)
            }
            
            db.collection("Column").document(columnId).updateData([
                "likes": tempLikes
            ]) { error in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func loadColumnLikes(columnId: String, completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Column").document(columnId).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }
            
            let likes = document.data()?["likes"] as? [String]
            completion(likes, nil)
        }
    }
    
    // MARK: - 댓글 수정
    func updateComment(columnId: String, userNickname: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        loadColumnComment(columnId: columnId) { comments, error in
            if let error = error {
                completion(error)
                return
            }
            
            var tempComments: [String] = comments ?? []
            
            if tempComments.contains(userNickname) {
                tempComments.remove(at: tempComments.firstIndex(of: userNickname)!)
            } else {
                tempComments.append(userNickname)
            }
            
            db.collection("Column").document(columnId).updateData([
                "comments": tempComments
            ]) { error in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            }
        }
    }

    private func loadColumnComment(columnId: String, completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Column").document(columnId).getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }
            
            let comments = document.data()?["comments"] as? [String]
            completion(comments, nil)
        }
    }
}
