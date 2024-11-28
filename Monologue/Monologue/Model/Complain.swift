//
//  Complain.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import Foundation

struct Complain: Codable {
    var reportedID: String // 신고 당한 ID, 메모 ID,"메모" or 칼럼 ID,"칼럼" or 코멘트 ID,"코멘트"
    var userNickname: String // 신고 한 유저 닉네임
    var reason: Int // 메뉴얼에 따른 신고 번호
    var date: Date // 날짜
}
