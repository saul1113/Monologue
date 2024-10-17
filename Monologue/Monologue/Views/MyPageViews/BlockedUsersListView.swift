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
    
    @State private var memoCount: [String: Int] = [:] // 닉네임별 메모 개수 저장
    @State private var columnCount: [String: Int] = [:] // 닉네임별 칼럼 개수 저장
    
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
                        ForEach(blockedUsers, id: \.self) { blockedUser in
                            NavigationLink {
                                UserProfileView(userInfo: blockedUser)
                            } label: {
                                UserRow(
                                    profileImageName: blockedUser.profileImageName,
                                    nickname: blockedUser.nickname,
                                    memoCount: memoCount[blockedUser.nickname] ?? 0,
                                    columnCount: columnCount[blockedUser.nickname] ?? 0,
                                    activeButtonText: "차단",
                                    inactiveButtonText: "차단 해제",
                                    onActive: {
                                        // 차단 로직
                                        print("\(blockedUser.nickname) 차단됨")
                                    },
                                    onInactive: {
                                        // 차단 해제 로직
                                        print("\(blockedUser.nickname) 차단 해제됨")
                                    }
                                )
                            }
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
            Task {
                await loadBlockedUsersAndCounts()
            }
        }
    }
    
    // 블락 유저 목록 및 해당 유저의 메모, 칼럼 개수 로드하는 함수
    private func loadBlockedUsersAndCounts() async {
        if let userInfo = userInfoStore.userInfo {
            do {
                blockedUsers = try await userInfoStore.loadUsersInfoByEmail(emails: userInfo.blocked)
                
                for blockedUser in blockedUsers {
                    memoCount[blockedUser.nickname] = try await userInfoStore.getMemoCount(userNickname: blockedUser.nickname)
                    columnCount[blockedUser.nickname] = try await userInfoStore.getColumnCount(userNickname: blockedUser.nickname)
                }
            } catch {
                print("Error loading blocked users or counts: \(error.localizedDescription)")
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
