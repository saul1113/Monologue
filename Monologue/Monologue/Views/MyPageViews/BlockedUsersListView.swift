//
//  BlockedUsersListView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct BlockedUsersListView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @Environment(\.dismiss) private var dismiss
    @State private var blockedUsers: [UserInfo] = []
    @State private var isActionActive = true // 차단 상태 관리
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            ScrollView {
                if blockedUsers.isEmpty {
                    VStack {
                        Text("차단한 사용자가 없습니다.")
                    }
                } else {
                    VStack {
                        ForEach(0..<blockedUsers.count) { index in
                            UserRow(
                                profileImageName: blockedUsers[index].profileImageName,
                                nickname: blockedUsers[index].nickname,
                                memoCount: userInfoStore.getMemoCount(userNickname: blockedUsers[index].nickname),
                                columnCount: userInfoStore.getMemoCount(userNickname: blockedUsers[index].nickname),
                                activeButtonText: "차단",
                                inactiveButtonText: "차단 해제",
                                onActive: {
                                    // 차단 로직
                                    print("\(blockedUsers[index].nickname) 차단됨")
                                },
                                onInactive: {
                                    // 차단 해제 로직
                                    print("\(blockedUsers[index].nickname) 차단 해제됨")
                                }
                            )
                        }
                    }
                }
            }
            .padding(.top, 25)
            .padding(.horizontal, 16)
            .foregroundStyle(.accent)
            .frame(maxHeight: .infinity, alignment: .top)
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
        .onAppear {
            if let userInfo = userInfoStore.userInfo {
                userInfoStore.loadUsersInfoByEmail(emails: userInfo.blocked, completion: { usersInfo, error in
                    blockedUsers = usersInfo ?? []
                })
            }
        }
    }
}

#Preview {
    NavigationStack {
        BlockedUsersListView()
            .environmentObject(AuthManager())
            .environmentObject(UserInfoStore())
            .environmentObject(MemoStore())
            .environmentObject(ColumnStore())
            .environmentObject(CommentStore())
    }
}
