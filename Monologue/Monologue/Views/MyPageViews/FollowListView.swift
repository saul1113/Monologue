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
    @State private var followers: [UserInfo] = []
    @State private var followings: [UserInfo] = []
    
    @State private var memoCount: [String: Int] = [:] // 이메일별 메모 개수 저장
    @State private var columnCount: [String: Int] = [:] // 이메일별 칼럼 개수 저장
    
    @State private var isFollowingStatus: [String: Bool] = [:] // 각 유저에 대한 팔로우 상태 추적
    
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
                        if followers.isEmpty {
                            Text("팔로워가 없습니다.")
                        } else {
                            ForEach(followers, id: \.self) { follower in
                                NavigationLink {
                                    MyPageView(userInfo: follower)
                                } label: {
                                    UserRow(
                                        profileImageName: follower.profileImageName,
                                        nickname: follower.nickname,
                                        memoCount: memoCount[follower.email] ?? 0,
                                        columnCount: columnCount[follower.email] ?? 0,
                                        // [String: Bool] 타입인 isFollowingStatus를 바인딩
                                        isActionActive: Binding(
                                                                get: { isFollowingStatus[follower.email] ?? false },
                                                                set: { isFollowingStatus[follower.email] = $0 }
                                                            ),
                                        // 내 계정이면 버튼 안 보임
                                        activeButtonText: follower.email == authManager.email ? nil : "팔로우",
                                        inactiveButtonText: follower.email == authManager.email ? nil : "팔로잉",
                                        onActive: {
                                            // 팔로우 로직
                                            Task {
                                                await userInfoStore.followUser(targetUserEmail: follower.email)
                                                isFollowingStatus[follower.email] = true
                                            }
                                        },
                                        onInactive: {
                                            // 언팔로우 로직
                                            Task {
                                                await userInfoStore.unfollowUser(targetUserEmail: follower.email)
                                                isFollowingStatus[follower.email] = false
                                            }
                                        },
                                        isFollowAction: true
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
                                    MyPageView(userInfo: following)
                                } label: {
                                    UserRow(
                                        profileImageName: following.profileImageName,
                                        nickname: following.nickname,
                                        memoCount: memoCount[following.email] ?? 0,
                                        columnCount: columnCount[following.email] ?? 0,
                                        isActionActive: Binding(
                                            get: { isFollowingStatus[following.email] ?? false },
                                            set: { isFollowingStatus[following.email] = $0 }
                                        ),
                                        // 내 계정이면 버튼 안 보임
                                        activeButtonText: following.email == authManager.email ? nil : "팔로우",
                                        inactiveButtonText: following.email == authManager.email ? nil : "팔로잉",
                                        onActive: {
                                            // 팔로우 로직
                                            Task {
                                                await userInfoStore.followUser(targetUserEmail: following.email)
                                                isFollowingStatus[following.email] = true
                                            }
                                        },
                                        onInactive: {
                                            // 언팔로우 로직
                                            Task {
                                                await userInfoStore.unfollowUser(targetUserEmail: following.email)
                                                isFollowingStatus[following.email] = false
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
                await loadFollowersAndFollowings()
                await loadFollowingStatus()
                print("isFollowingStatus: \(isFollowingStatus)")
            }
        }
    }
    
    // 팔로워, 팔로잉 목록 불러오고 각 메모 및 칼럼 개수 로드 함수
    private func loadFollowersAndFollowings() async {
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
    
    // 로그인된 유저가 각 유저를 팔로우하고 있는지 여부를 확인하는 함수
    private func loadFollowingStatus() async {
        for follower in followers {
            isFollowingStatus[follower.email] = await userInfoStore.checkIfFollowing(targetUserEmail: follower.email)
        }
        
        for following in followings {
            isFollowingStatus[following.email] = await userInfoStore.checkIfFollowing(targetUserEmail: following.email)
        }
    }
}
