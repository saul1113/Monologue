//
//  UserProfileView.swift
//  Monologue
//
//  Created by Hyojeong on 10/17/24.
//

import SwiftUI

// 다른 유저들 프로필 뷰
struct OtherUserPageView: View {
    @Binding var userInfo: UserInfo
    
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedSegment: String = "메모"
    @State private var userMemos: [Memo] = [] // 사용자가 작성한 메모들
    @State private var userColumns: [Column] = [] // 사용자가 작성한 칼럼들
    @State private var isShowingEllipsisSheet: Bool = false
    @State private var isShowingReportSheet: Bool = false
    @State private var isShowingBlockAlert: Bool = false
    @State private var isFollowing: Bool = false
    @State private var isBlockedByMe: Bool = false // 내가 타인을 블락한 상태
    @State private var isBlockedByThem: Bool = false // 타인이 나를 블락한 상태
    @State var filters: [String]? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()
                
                VStack {
                    // MARK: - 프로필 정보(프사, 닉네임, 자기소개)
                    HStack {
                        ProfileImageView(profileImageName: userInfo.profileImageName, size: 77)
                            .padding(.trailing, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(userInfo.nickname)
                                .font(.system(size: 18))
                                .bold()
                            
                            Text(userInfo.introduction.isEmpty ? "자기소개가 없습니다." : userInfo.introduction)
                                .font(.system(size: 16))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)
                    .padding(.top, 15)
                    
                    // MARK: - 메모, 칼럼, 팔로워, 팔로잉 count
                    HStack(spacing: 20) {
                        HStack {
                            Text("메모")
                            Text("\(userMemos.count)")
                                .bold()
                        }
                        .padding(.horizontal, 2)
                        
                        Divider()
                        
                        HStack {
                            Text("칼럼")
                            Text("\(userColumns.count)")
                                .bold()
                        }
                        .padding(.horizontal, 2)
                        
                        Divider()
                        
                        NavigationLink {
                            FollowListView(selectedSegment: "팔로워", userInfo: $userInfo)
                        } label: {
                            HStack {
                                Text("팔로워")
                                Text("\(userInfoStore.followersCount)")
                                    .bold()
                            }
                            .padding(.horizontal, 2)
                        }
                        
                        Divider()
                        
                        NavigationLink {
                            FollowListView(selectedSegment: "팔로잉", userInfo: $userInfo)
                        } label: {
                            HStack {
                                Text("팔로잉")
                                Text("\(userInfoStore.followingsCount)")
                                    .bold()
                            }
                            .padding(.horizontal, 2)
                        }
                    }
                    .font(.system(size: 14))
                    .frame(height: 22)
                    .padding(.bottom, 30)
                    
                    // MARK: - 팔로우(차단), 알림 설정
                    HStack {
                        if isBlockedByMe {
                            Button {
                                isShowingBlockAlert = true
                            } label: {
                                Text("차단 해제")
                                    .modifier(FilledButtonStyle())
                            }
                        } else if isBlockedByThem {
                            Text("차단됨")
                                .modifier(BorderedButtonStyle())
                        } else {
                            Button {
                                Task {
                                    if isFollowing {
                                        // 언팔로우 로직
                                        await userInfoStore.unfollowUser(targetUserEmail: userInfo.email)
                                        isFollowing = false
                                    } else {
                                        // 팔로우 로직
                                        await userInfoStore.followUser(targetUserEmail: userInfo.email)
                                        isFollowing = true
                                    }
                                }
                            } label: {
                                if isFollowing {
                                    Text("팔로잉")
                                        .modifier(BorderedButtonStyle())
                                } else {
                                    Text("팔로우")
                                        .modifier(FilledButtonStyle())
                                }
                            }
                        }
                        
                        // 알림 설정
                        Button {
                            // 알림 설정 어떻게 할지...
                        } label: {
                            Text("알림 설정")
                                .modifier(BorderedButtonStyle())
                        }
                    }
                    .padding(.bottom, 25)

                    // MARK: - 메모 및 칼럼 뷰
                    if isBlockedByMe {
                        Text("차단한 유저의 게시물입니다.")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    } else if isBlockedByThem {
                        VStack(alignment: .center, spacing: 10) {
                            Text("회원님이 나를 차단했습니다.")
                                .font(.title3)
                                .bold()
                            
                            Text("회원님을 팔로우하거나 게시물을 볼 수 없습니다.")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.top, 10)
                        
                    } else {
                        CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)
                        
                        GeometryReader { geometry in
                            HStack(spacing: 0) {
                                // 메모가 비어있을 경우
                                if userMemos.isEmpty {
                                    Text("작성된 메모가 없습니다.")
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                } else {
                                    MemoView(filters: $filters, userMemos: userMemos)
                                        .frame(width: geometry.size.width)
                                }
                                
                                // 칼럼이 비어있을 경우
                                if userColumns.isEmpty {
                                    Text("작성된 칼럼이 없습니다.")
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                } else {
                                    ColumnView(filteredColumns: $userColumns)
                                        .frame(width: geometry.size.width)
                                }
                            }
                            .offset(x: selectedSegment == "메모" ? 0 : -geometry.size.width)
                            .animation(.easeInOut, value: selectedSegment)
                            .gesture(
                                DragGesture(minimumDistance: 35)
                                    .onChanged { value in
                                        if value.translation.width > 0 {
                                            selectedSegment = "메모"
                                        } else if value.translation.width < 0 {
                                            selectedSegment = "칼럼"
                                        }
                                    }
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, -16)
                    }
                }
                .padding(.horizontal, 16)
                .foregroundStyle(.accent)
            }
            .navigationBarBackButtonHidden(true)
            // MARK: - Toolbar (좌)Back, (우)...버튼
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingEllipsisSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                    }
                    .sheet(isPresented: $isShowingEllipsisSheet) {
                        EllipsisCustomSheet(buttonOptions: [SheetButtonOption(type: .share,
                                                                              action: { }),
                                                            SheetButtonOption(type: .block,
                                                                              action: { }),
                                                            SheetButtonOption(type: .report,
                                                                              action: { }),
                                                            SheetButtonOption(type: .cancel,
                                                                              action: { isShowingEllipsisSheet = false })],
                                            sharedString: userInfo.nickname,
                                            reportOrDeleteTitle: .user,
                                            isShowingReportSheet: $isShowingReportSheet,
                                            isShowingBlockAlert: $isShowingBlockAlert,
                                            isShowingEllipsisSheet: $isShowingEllipsisSheet,
                                            isShowingDeleteAlert: .constant(false),
                                            isBlocked: isBlockedByMe)
                        .presentationDetents([.height(240)])
                    }
                }
            }
            .onAppear {
                Task {
                    await loadUserPosts()
                    isFollowing = await userInfoStore.checkIfFollowing(targetUserEmail: userInfo.email)
                    isBlockedByMe = await userInfoStore.checkIfBlocked(targetUserEmail: userInfo.email)
                    isBlockedByThem = await userInfoStore.checkIfBlocked(targetUserEmail: userInfo.email)
                }
                userInfoStore.observeUserFollowData(email: userInfo.email)
                setupNavigationBarAppearance(backgroundColor: .background)
            }
            .onDisappear {
                userInfoStore.removeListener()
            }
            .customAlert(isPresented: $isShowingBlockAlert,
                         transition: .opacity,
                         title: isBlockedByMe ? "차단 해제하기" : "차단하기",
                         message: isBlockedByMe ? "해당 유저의 차단을 해제하면 게시물을 다시 볼 수 있게 됩니다." : "차단된 사람은 회원님을 팔로우할 수 없으며, 회원님의 게시물을 볼 수 없게 됩니다.",
                         primaryButtonTitle: isBlockedByMe ? "차단 해제" : "차단") { isBlockedByMe ? unblockUser() : blockUser() }
        }
    }
    
    // 유저 메모 및 칼럼 업데이트
    private func loadUserPosts() async {
        do {
            userMemos = try await memoStore.loadMemosByUserEmail(email: userInfo.email)
            userColumns = try await columnStore.loadColumnsByUserEmail(email: userInfo.email)
        } catch {
            print("Error loading memos or columns: \(error.localizedDescription)")
        }
    }
    
    // 유저 차단
    private func blockUser() {
        Task {
            try await userInfoStore.blockUser(blockedEmail: userInfo.email)
            isBlockedByMe = true
        }
    }
    
    // 유저 차단 해제
    private func unblockUser() {
        Task {
            try await userInfoStore.unblockUser(blockedEmail: userInfo.email)
            isBlockedByMe = false
        }
    }
}
