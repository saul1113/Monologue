//
//  BlockedUserRow.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct BlockedUserRow: View {
    let profileImageName: String
    let nickname: String
    let memoCount: Int
    let columnCount: Int
    
    @State private var isBlocked: Bool = true // 차단 상태 관리
    
    var body: some View {
        HStack {
            Circle() // profileImageName
                .frame(width: 50, height: 50)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(nickname)
                    .font(.system(size: 16, weight: .semibold))
                
                Text("메모 \(memoCount) · 칼럼 \(columnCount)") // 메모, 칼럼 수
                    .font(.system(size: 14))
                    .opacity(0.5)
            }
            
            Spacer()
            
            Button {
                if isBlocked {
                    // 차단 해제 로직 호출
                } else {
                    // 차단 로직 호출
                }
                
                isBlocked.toggle() // 상태 토글
            } label: {
                Text(isBlocked ? "차단 해제" : "차단")
                    .font(.system(size: 15))
                    .frame(width: 90, height: 30)
                    .foregroundStyle(isBlocked ? .white : .accent)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(isBlocked ? Color.accent : Color.clear)) // 배경색 변경
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isBlocked ? .clear : .accent.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
        .padding(.bottom, 24)
    }
}
