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
        let columnRef = db.collection("Column").document(column.id)
        
        columnRef.setData([
            "title": column.title,
            "content": column.content,
            "email": column.email,
            "userNickname": column.userNickname,
            "categories": column.categories,
            "likes": column.likes,
            "date": Timestamp(date: column.date)
        ]) { error in
            if let error = error {
                completion(error)
                return
            }
            
            if let comments = column.comments {
                let dispatchGroup = DispatchGroup()
                
                for comment in comments {
                    dispatchGroup.enter()
                    let commentRef = columnRef.collection("comments").document(comment.id)
                    commentRef.setData([
                        "content": comment.content,
                        "date": comment.date,
                        "userNickname": comment.userNickname
                    ]) { error in
                        if let error = error {
                            completion(error)
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func addColumn(column: Column) async throws {
        let db = Firestore.firestore()
        
        let columnRef = db.collection("Column").document(column.id)
        try await columnRef.setData([
            "title": column.title,
            "content": column.content,
            "email": column.email,
            "userNickname": column.userNickname,
            "categories": column.categories,
            "likes": column.likes,
            "date": Timestamp(date: column.date)
        ])
        
        if let comments = column.comments {
            for comment in comments {
                let commentRef = columnRef.collection("comments").document(comment.id)
                try await commentRef.setData([
                    "content": comment.content,
                    "date": comment.date,
                    "userNickname": comment.userNickname
                ])
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
                Task {
                    do {
                        let column = try await Column(document: document)
                        columns.append(column)
                    } catch {
                        print("loadColumn error: \(error.localizedDescription)")
                    }
                }
                
            }
            completion(columns, nil)
        }
    }
    
    func loadColumn() async throws -> [Column] {
        let db = Firestore.firestore()
        
        let querySnapshot = try await db.collection("Column").getDocuments()
        
        var columns: [Column] = []
        
        for document in querySnapshot.documents {
            do {
                let column = try await Column(document: document)
                columns.append(column)
            } catch {
                print("loadColumn error: \(error.localizedDescription)")
            }
        }
        
        return columns
    }
    
    // MARK: - 칼럼 유저 이메일로 로드
    func loadColumnsByUserEmail(email: String, completion: @escaping ([Column]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Column")
            .whereField("email", isEqualTo: email)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var columns: [Column] = []
                
                for document in querySnapshot!.documents {
                    Task {
                        do {
                            let column = try await Column(document: document)
                            columns.append(column)
                        } catch {
                            print("loadColumnsByUserNickname error: \(error.localizedDescription)")
                        }
                    }
                }
                completion(columns, nil)
            }
    }
    
    func loadColumnsByUserEmail(email: String) async throws -> [Column] {
        let db = Firestore.firestore()
        
        let querySnapshot = try await db.collection("Column")
            .whereField("email", isEqualTo: email)
            .getDocuments()
        
        var columns: [Column] = []
        
        for document in querySnapshot.documents {
            do {
                let column = try await Column(document: document)
                columns.append(column)
            } catch {
                print("loadColumnsByUserNickname error: \(error.localizedDescription)")
            }
        }
        
        return columns
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
                    Task {
                        do {
                            let column = try await Column(document: document)
                            columns.append(column)
                        } catch {
                            print("loadColumnsByCategories error: \(error.localizedDescription)")
                        }
                    }
                }
                
                completion(columns, nil)
            }
    }
    
    func loadColumnsByCategories(categories: [String]) async throws -> [Column] {
        let db = Firestore.firestore()
        
        let querySnapshot = try await db.collection("Column")
            .whereField("categories", arrayContains: categories[0])
            .getDocuments()
        
        var columns: [Column] = []
        
        for document in querySnapshot.documents {
            do {
                let column = try await Column(document: document)
                columns.append(column)
            } catch {
                print("loadColumnsByCategories error: \(error.localizedDescription)")
            }
        }
        
        return columns
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
    
    func deleteColumn(columnId: String) async throws {
        let db = Firestore.firestore()
        
        try await db.collection("Column").document(columnId).delete()
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
    
    private func loadColumnLikes(columnId: String) async throws -> [String]? {
        let db = Firestore.firestore()
        
        let document = try await db.collection("Column").document(columnId).getDocument()
        
        guard let data = document.data() else {
            return nil
        }
        
        return data["likes"] as? [String]
    }
    
    
    
    func updateLikes(columnId: String, userNickname: String) async throws {
        let db = Firestore.firestore()
        
        let likes = try await loadColumnLikes(columnId: columnId)
        
        var tempLikes: [String] = likes ?? []
        
        if tempLikes.contains(userNickname) {
            tempLikes.remove(at: tempLikes.firstIndex(of: userNickname)!)
        } else {
            tempLikes.append(userNickname)
        }
        
        try await db.collection("Column").document(columnId).updateData([
            "likes": tempLikes
        ])
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
    
    func updateComment(columnId: String, userNickname: String) async throws {
        let db = Firestore.firestore()
        
        let comments = try await loadColumnComment(columnId: columnId)
        
        var tempComments: [String] = comments ?? []
        
        if tempComments.contains(userNickname) {
            tempComments.remove(at: tempComments.firstIndex(of: userNickname)!)
        } else {
            tempComments.append(userNickname)
        }
        
        try await db.collection("Column").document(columnId).updateData([
            "comments": tempComments
        ])
    }
    
    private func loadColumnComment(columnId: String) async throws -> [String]? {
        let db = Firestore.firestore()
        
        let document = try await db.collection("Column").document(columnId).getDocument()
        
        guard document.exists else {
            return nil
        }
        
        let comments = document.data()?["comments"] as? [String]
        return comments
    }
}
