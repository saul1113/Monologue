//
//  FollowListView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct FollowListView: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @Environment(\.dismiss) private var dismiss
    @State private var followers: [UserInfo] = []
    @State private var followings: [UserInfo] = []
    
    @State private var isActionActive = true // 팔로우 상태 관리
    
    @State var selectedSegment: String // 마이페이지뷰에서 받음
    private let segments = ["팔로워", "팔로잉"] // 세그먼트 버튼
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            CustomSegmentView(segment1: "팔로워", segment2: "팔로잉", selectedSegment: $selectedSegment)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 10)
            
            ScrollView {
                VStack {
                    if selectedSegment == "팔로워" {
                        // 팔로워 뷰
                        if followers.isEmpty {
                            Text("팔로워가 없습니다.")
                        } else {
                            ForEach(0..<followers.count) { index in
                                UserRow(
                                    profileImageName: followers[index].profileImageName,
                                    nickname: followers[index].nickname,
                                    memoCount: userInfoStore.getMemoCount(userNickname: followers[index].nickname),
                                    columnCount: userInfoStore.getColumnCount(userNickname: followers[index].nickname),
                                    activeButtonText: "팔로우",
                                    inactiveButtonText: "팔로잉",
                                    onActive: {
                                        // 팔로우 로직
                                        print("\(followers[index].nickname) 다시 팔로우")
                                    },
                                    onInactive: {
                                        // 언팔로우 로직
                                        print("\(followers[index].nickname) 언팔")
                                    }
                                )
                            }
                        }
                    } else {
                        // 팔로잉 뷰
                        if followings.isEmpty {
                            Text("팔로잉이 없습니다.")
                        } else {
                            ForEach(0..<followings.count) { index in
                                UserRow(
                                    profileImageName: followers[index].profileImageName,
                                    nickname: followers[index].nickname,
                                    memoCount: userInfoStore.getMemoCount(userNickname: followers[index].nickname),
                                    columnCount: userInfoStore.getColumnCount(userNickname: followers[index].nickname),
                                    activeButtonText: "팔로우",
                                    inactiveButtonText: "팔로잉",
                                    onActive: {
                                        // 팔로우 로직
                                        print("\(followers[index].nickname) 다시 팔로우")
                                    },
                                    onInactive: {
                                        // 언팔로우 로직
                                        print("\(followers[index].nickname) 언팔")
                                    }
                                )
                            }
                        }
                    }
                }
                .foregroundStyle(.accent)
                .padding(.horizontal, 16)
            }
            .padding(.top, 70)
        }
        .navigationTitle("북극성") // nickname 데이터로 변경 예정
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
                    // 팔로워 목록 불러오기
                    userInfoStore.loadUsersInfoByNickname(nicknames: userInfo.followers, completion: { usersInfo, error in
                        followers = usersInfo ?? []
                    })
                    
                    // 팔로잉 목록 불러오기
                    userInfoStore.loadUsersInfoByNickname(nicknames: userInfo.followings, completion: { usersInfo, error in
                        followings = usersInfo ?? []
                    })
                }
        }
    }
}

#Preview {
    NavigationStack {
        FollowListView(selectedSegment: "팔로워")
            .environmentObject(AuthManager())
            .environmentObject(UserInfoStore())
            .environmentObject(MemoStore())
            .environmentObject(ColumnStore())
            .environmentObject(CommentStore())
    }
}
