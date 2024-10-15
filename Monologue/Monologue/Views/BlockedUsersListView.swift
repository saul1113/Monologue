//
//  BlockedUsersListView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct BlockedUsersListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isActionActive = true // 차단 상태 관리
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            ScrollView {
                // ForEach로 변경 예정
                VStack {
                    ForEach($users) { $user in
                        UserRow(
                            profileImageName: user.profileImageName,
                            nickname: user.nickname,
                            memoCount: user.memoCount,
                            columnCount: user.columnCount,
                            isActionActive: $user.isActionActive, // 개별 상태 관리
                            activeButtonText: "차단",
                            inactiveButtonText: "차단 해제",
                            onActive: {
                                // 차단 로직
                                print("\(user.nickname) 차단됨")
                            },
                            onInactive: {
                                // 차단 해제 로직
                                print("\(user.nickname) 차단 해제됨")
                            }
                        )
                    }
                }
                .padding(.top, 25)
                .padding(.horizontal, 16)
                .foregroundStyle(.accent)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationTitle("차단 유저 목록")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // 기본 백 버튼 숨기기
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BlockedUsersListView()
    }
}
