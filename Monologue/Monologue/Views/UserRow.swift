//
//  UserRow.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct UserRow: View {
    let profileImageName: String
    let nickname: String
    let memoCount: Int
    let columnCount: Int
    
    @Binding var isActionActive: Bool // 상태 관리
    
    // 버튼 텍스트
    let activeButtonText: String
    let inactiveButtonText: String
    
    // 상태 로직
    let onActive: () -> Void
    let onInactive: () -> Void
    
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
                if isActionActive {
                    // 차단 해제, 언팔로우 로직
                    onInactive()
                } else {
                    // 차단, 팔로우 로직
                    onActive()
                }
                
                isActionActive.toggle() // 상태 토글
            } label: {
                Text(isActionActive ? inactiveButtonText : activeButtonText)
                    .font(.system(size: 15))
                    .frame(width: 90, height: 30)
                    .foregroundStyle(isActionActive ? .white : .accent)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(isActionActive ? .accent : .clear)) // 배경색 변경
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(isActionActive ? .clear : .accent.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
        .padding(.bottom, 24)
    }
}
