//
//  FollowListView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct FollowListView: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager: AuthManager
    
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedSegment: String // 마이페이지뷰에서 받음
    
    @Binding var userInfo: UserInfo // 특정 유저의 정보를 받음(본인 or 타인)
    
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
                        if userInfoStore.followers.isEmpty {
                            Text("팔로워가 없습니다.")
                        } else {
                            ForEach(userInfoStore.followers, id: \.self) { follower in
                                NavigationLink {
                                    MyPageView(userInfo: follower)
                                } label: {
                                    UserRow(
                                        profileImageName: follower.profileImageName,
                                        nickname: follower.nickname,
                                        memoCount: userInfoStore.memoCount[follower.email] ?? 0,
                                        columnCount: userInfoStore.columnCount[follower.email] ?? 0,
                                        isActionActive: Binding(
                                            get: { userInfoStore.isFollowingStatus[follower.email] ?? false },
                                            set: { userInfoStore.isFollowingStatus[follower.email] = $0 }
                                        ),
                                        // 내 계정이면 버튼 안 보임
                                        activeButtonText: follower.email == authManager.email ? nil : "팔로우",
                                        inactiveButtonText: follower.email == authManager.email ? nil : "팔로잉",
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
                                        },
                                        isFollowAction: true
                                    )
                                }
                            }
                        }
                    } else {
                        // MARK: - 팔로잉 뷰
                        if userInfoStore.followings.isEmpty {
                            Text("팔로잉이 없습니다.")
                        } else {
                            ForEach(userInfoStore.followings, id: \.self) { following in
                                NavigationLink {
                                    MyPageView(userInfo: following)
                                } label: {
                                    UserRow(
                                        profileImageName: following.profileImageName,
                                        nickname: following.nickname,
                                        memoCount: userInfoStore.memoCount[following.email] ?? 0,
                                        columnCount: userInfoStore.columnCount[following.email] ?? 0,
                                        isActionActive: Binding(
                                            get: { userInfoStore.isFollowingStatus[following.email] ?? false },
                                            set: { userInfoStore.isFollowingStatus[following.email] = $0 }
                                        ),
                                        // 내 계정이면 버튼 안 보임
                                        activeButtonText: following.email == authManager.email ? nil : "팔로우",
                                        inactiveButtonText: following.email == authManager.email ? nil : "팔로잉",
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
                                        },
                                        isFollowAction: true
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
        .navigationTitle(userInfo.nickname)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
                await userInfoStore.loadFollowersAndFollowings(for: userInfo)
                await userInfoStore.loadFollowingStatus()
            }
        }
    }
}
