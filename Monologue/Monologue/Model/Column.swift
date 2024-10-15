//
//  Column.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation

struct Column: Codable, Identifiable {
    var id: String = UUID().uuidString
    var content: String // 칼럼 내용
    var userNickname: String // 유저 닉네임
    var categories: [String] // 카테고리
    var likes: [String] // 좋아요 개수
    var comments: [String] // 코멘트 ID
    var date: Date // 날짜
}
