//
//  Comment.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation

struct Comment: Codable, Identifiable {
    var id: String = UUID().uuidString
    var content: String // 코멘트 내용
    var date: Date // 날짜
}
