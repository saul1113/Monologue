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
    
    @State private var memoCount: [String: Int] = [:] // 닉네임별 메모 개수 저장
    @State private var columnCount: [String: Int] = [:] // 닉네임별 칼럼 개수 저장
    
    @State private var isActionActive = true // 팔로우 상태 관리
    
    @State var selectedSegment: String // 마이페이지뷰에서 받음
    private let segments = ["팔로워", "팔로잉"] // 세그먼트 버튼
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            CustomSegmentView(segment1: "팔로워",
                              segment2: "팔로잉",
                              selectedSegment: $selectedSegment)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            
            ScrollView {
                VStack {
                    if selectedSegment == "팔로워" {
                        // MARK: - 팔로워 뷰
                        if followers.isEmpty {
                            Text("팔로워가 없습니다.")
                        } else {
                            ForEach(followers, id: \.self) { follower in
                                NavigationLink {
                                    UserProfileView(userInfo: follower)
                                } label: {
                                    UserRow(
                                        profileImageName: follower.profileImageName,
                                        nickname: follower.nickname,
                                        memoCount: memoCount[follower.nickname] ?? 0,
                                        columnCount: columnCount[follower.nickname] ?? 0,
                                        activeButtonText: "팔로우",
                                        inactiveButtonText: "팔로잉",
                                        onActive: {
                                            // 팔로우 로직
                                            Task {
                                                await userInfoStore.followUser(targetUserEmail: follower.email)
                                            }
                                        },
                                        onInactive: {
                                            // 언팔로우 로직
                                            Task {
                                                await userInfoStore.unfollowUser(targetUserEmail: follower.email)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    } else {
                        // MARK: - 팔로잉 뷰
                        if followings.isEmpty {
                            Text("팔로잉이 없습니다.")
                        } else {
                            ForEach(followings, id: \.self) { following in
                                NavigationLink {
                                    UserProfileView(userInfo: following)
                                } label: {
                                    UserRow(
                                        profileImageName: following.profileImageName,
                                        nickname: following.nickname,
                                        memoCount: memoCount[following.nickname] ?? 0,
                                        columnCount: columnCount[following.nickname] ?? 0,
                                        activeButtonText: "팔로우",
                                        inactiveButtonText: "팔로잉",
                                        onActive: {
                                            // 팔로우 로직
                                            Task {
                                                await userInfoStore.followUser(targetUserEmail: following.email)
                                            }
                                        },
                                        onInactive: {
                                            // 언팔로우 로직
                                            Task {
                                                await userInfoStore.unfollowUser(targetUserEmail: following.email)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
                .foregroundStyle(.accent)
                .padding(.horizontal, 16)
            }
            .padding(.top, 70)
        }
        .navigationTitle(userInfoStore.userInfo?.nickname ?? "")
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
                await loadFollowersAndFollowings()
            }
        }
    }
    
    // 팔로워, 팔로잉 목록 불러오고 각 메모 및 칼럼 개수 로드 함수
    private func loadFollowersAndFollowings() async {
        if let userInfo = userInfoStore.userInfo {
            do {
                // 팔로워
                followers = try await userInfoStore.loadUsersInfoByEmail(emails: userInfo.followers)
                
                for follower in followers {
                    memoCount[follower.email] = try await userInfoStore.getMemoCount(email: follower.email)
                    columnCount[follower.email] = try await userInfoStore.getColumnCount(email: follower.email)
                }
                
                // 팔로잉
                followings = try await userInfoStore.loadUsersInfoByEmail(emails: userInfo.followings)
                
                for following in followings {
                    memoCount[following.email] = try await userInfoStore.getMemoCount(email: following.email)
                    columnCount[following.email] = try await userInfoStore.getColumnCount(email: following.email)
                }
            } catch {
                print("Error loading followers or followings: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        FollowListView(selectedSegment: "팔로워")
            .environmentObject(UserInfoStore())
    }
}
