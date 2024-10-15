//
//  ProfileInfo.swift
//  Monologue
//
//  Created by 김종혁 on 10/14/24.
//

import Foundation

// 사용자 관리
@MainActor
struct ProfileInfo: Codable {
    var nickname: String                    // 닉네임
    var registrationDate: Date              // 가입날짜
    
    // 가입 날짜 Formatter 생성
    var formattedRegistration: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일 HH시 mm분"
        return formatter.string(from: registrationDate)
    }
}
