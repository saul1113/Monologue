//
//  MemoStore.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation
import Observation
import FirebaseCore
import FirebaseFirestore

class MemoStore: ObservableObject {
    @Published var memos: [Memo] = []
    @Published var filterMemos: [Memo] = []
        
    // MARK: - 메모 전체 추가, 수정
    func addMemo(memo: Memo, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Memo").document(memo.id).setData([
            "content": memo.content,
            "userNickname": memo.userNickname,
            "font": memo.font,
            "backgroundImageName": memo.backgroundImageName,
            "categories": memo.categories,
            "likes": memo.likes,
            "comments": memo.comments,
            "date": Timestamp(date: memo.date),
            "lineCount": memo.lineCount
        ]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func addMemo(memo: Memo) async throws {
        let db = Firestore.firestore()
        
        try await db.collection("Memo").document(memo.id).setData([
            "content": memo.content,
            "userNickname": memo.userNickname,
            "font": memo.font,
            "backgroundImageName": memo.backgroundImageName,
            "categories": memo.categories,
            "likes": memo.likes,
            "comments": memo.comments,
            "date": Timestamp(date: memo.date),
            "lineCount": memo.lineCount
        ])
    }
    
    // MARK: - 메모 전체 로드
    func loadMemos(completion: @escaping ([Memo]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Memo").getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var memos: [Memo] = []
                
                for document in querySnapshot!.documents {
                    let memo = Memo(document: document)
                    
                    memos.append(memo)
                    self.memos = memos
                }
                completion(memos, nil)
            }
    }
    
    func loadMemos() async throws -> [Memo] {
            let db = Firestore.firestore()
            
            let querySnapshot = try await db.collection("Memo").getDocuments()
            
            var memos: [Memo] = []
            
            for document in querySnapshot.documents {
                let memo = Memo(document: document)
                memos.append(memo)
            }
            
            self.memos = memos
            return memos
        }
        
    
    // MARK: - 메모 유저 닉네임으로 로드
    func loadMemosByUserNickname(userNickname: String, completion: @escaping ([Memo]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Memo")
            .whereField("userNickname", isEqualTo: userNickname)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var memos: [Memo] = []
                
                for document in querySnapshot!.documents {
                    let memo = Memo(document: document)
                    
                    memos.append(memo)
                }
                completion(memos, nil)
            }
    }
    
    func loadMemosByUserNickname(userNickname: String) async throws -> [Memo] {
            let db = Firestore.firestore()
            
            let querySnapshot = try await db.collection("Memo")
                .whereField("userNickname", isEqualTo: userNickname)
                .getDocuments()
            
            var memos: [Memo] = []
            
            for document in querySnapshot.documents {
                let memo = Memo(document: document)
                memos.append(memo)
            }
            
            return memos
        }
    
    // MARK: - 메모 카테고리들로 로드
    func loadMemosByCategories(categories: [String], completion: @escaping ([Memo]?, Error?) -> Void) {
        let db = Firestore.firestore()
            
            db.collection("Memo")
            .whereField("categories", arrayContains: categories[0])
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    
                    var memos: [Memo] = []
                    
                    for document in querySnapshot!.documents {
                        let memo = Memo(document: document)
                        
                        memos.append(memo)
                    }
                    
                    completion(memos, nil)
                }
    }
    
    func loadMemosByCategories(categories: [String]) async throws -> [Memo] {
            let db = Firestore.firestore()
            
            let querySnapshot = try await db.collection("Memo")
                .whereField("categories", arrayContains: categories[0])
                .getDocuments()
            
            var memos: [Memo] = []
            
            for document in querySnapshot.documents {
                let memo = Memo(document: document)
                memos.append(memo)
            }
            
            return memos
        }
    
    // MARK: - 메모 아이디로 메모 삭제
    func deleteMemo(memoId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Memo").document(memoId).delete { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func deleteMemo(memoId: String) async throws {
            let db = Firestore.firestore()
            
            try await db.collection("Memo").document(memoId).delete()
        }
    
    // MARK: - 좋아요 수정
    func updateLikes(memoId: String, userNickname: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        loadMemoLikes(memoId: memoId) { likes, error in
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
            
            db.collection("Memo").document(memoId).updateData([
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
    
    private func loadMemoLikes(memoId: String, completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Memo").document(memoId).getDocument { (document, error) in
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
    
    func updateLikes(memoId: String, userNickname: String) async throws {
           let db = Firestore.firestore()
           
           let likes = try await loadMemoLikes(memoId: memoId)
           
           var tempLikes: [String] = likes ?? []
           
           if tempLikes.contains(userNickname) {
               tempLikes.remove(at: tempLikes.firstIndex(of: userNickname)!)
           } else {
               tempLikes.append(userNickname)
           }
           
           try await db.collection("Memo").document(memoId).updateData([
               "likes": tempLikes
           ])
       }
       
       private func loadMemoLikes(memoId: String) async throws -> [String]? {
           let db = Firestore.firestore()
           
           let document = try await db.collection("Memo").document(memoId).getDocument()
           
           guard let data = document.data(), document.exists else {
               return nil
           }
           
           let likes = data["likes"] as? [String]
           return likes
       }
    
    // MARK: - 댓글 수정
    func updateComment(memoId: String, userNickname: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        loadMemoComment(memoId: memoId) { comments, error in
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
            
            db.collection("Memo").document(memoId).updateData([
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

    private func loadMemoComment(memoId: String, completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Memo").document(memoId).getDocument { (document, error) in
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
    
    func updateComment(memoId: String, userNickname: String) async throws {
        let db = Firestore.firestore()
        
        let comments = try await loadMemoComment(memoId: memoId)
        
        var tempComments: [String] = comments ?? []
        
        if let index = tempComments.firstIndex(of: userNickname) {
            tempComments.remove(at: index)
        } else {
            tempComments.append(userNickname)
        }
        
        try await db.collection("Memo").document(memoId).updateData([
            "comments": tempComments
        ])
    }

    private func loadMemoComment(memoId: String) async throws -> [String]? {
        let db = Firestore.firestore()
        
        let document = try await db.collection("Memo").document(memoId).getDocument()
        
        guard let data = document.data(), document.exists else {
            return nil
        }
        
        let comments = data["comments"] as? [String]
        return comments
    }
}
