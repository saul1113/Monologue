//
//  UserProfileView.swift
//  Monologue
//
//  Created by Hyojeong on 10/17/24.
//

import SwiftUI

// 다른 유저들 프로필 뷰
struct UserProfileView: View {
    public let userInfo: UserInfo
    
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
    @State private var isFollowing: Bool = false // 팔로우 상태 확인
    
    @State var filters: [String]? = nil
    
    // 기본 이니셜라이저
    init(userInfo: UserInfo) {
        self.userInfo = userInfo
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()
                
                VStack {
                    // 프사, 닉, 상메
                    HStack {
                        ProfileImageView(profileImageName: userInfo.profileImageName,
                                         size: 77)
                        .padding(.trailing, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(userInfo.nickname)
                                .font(.system(size: 18))
                                .bold()
                            
                            Text(userInfo.introduction.isEmpty ? "자기소개가 없습니다." : userInfo.introduction)
                                .font(.system(size: 16))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
                    .padding(.bottom, 20)
                    .padding(.top, 15)
                    
                    // 메모, 칼럼, 팔로워, 팔로잉 수
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
                        
                        // NavigationLink로 변경 예정
                        Button {
                            
                        } label: {
                            HStack {
                                Text("팔로워")
                                Text("\(userInfoStore.followersCount)")
                                    .bold()
                            }
                            .padding(.horizontal, 2)
                        }
                        
                        Divider()
                        
                        // NavigationLink로 변경 예정
                        Button {
                            
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
                    
                    // 프로필 편집, 공유 버튼
                    HStack {
                        Button {
                            if isFollowing {
                                Task {
                                    await userInfoStore.unfollowUser(targetUserEmail: userInfo.email)
                                    isFollowing = false
                                }
                            } else {
                                Task {
                                    await userInfoStore.followUser(targetUserEmail: userInfo.email)
                                    isFollowing = true
                                }
                            }
                        } label: {
                            if isFollowing {
                                Text("팔로잉")
                                    .font(.system(size: 15))
                                    .frame(maxWidth: .infinity, minHeight: 30)
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(.accent, lineWidth: 1)
                                    )
                            } else {
                                Text("팔로우")
                                    .font(.system(size: 15))
                                    .frame(maxWidth: .infinity, minHeight: 30)
                                    .foregroundStyle(.white)
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .fill(.accent))
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            Text("알림 설정")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, minHeight: 30)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.accent, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.bottom, 30)
                    
                    CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)
                    
                    // 버튼 & 스와이프 제스처 사용
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            MemoView(filters: $filters, userMemos: userMemos)
                                .frame(width: geometry.size.width)
                            
                            ColumnView(filteredColumns: $userColumns, mode: .myPage)
                                .frame(width: geometry.size.width)
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
                .padding(.horizontal, 16)
                .foregroundStyle(.accent)
            }
            .navigationBarBackButtonHidden(true) // 기본 백 버튼 숨기기
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
                                                                              action: { print("유저 차단") }),
                                                            SheetButtonOption(type: .report,
                                                                              action: { }),
                                                            SheetButtonOption(type: .cancel,
                                                                              action: { isShowingEllipsisSheet = false })],
                                            sharedString: userInfo.nickname,
                                            reportOrDeleteTitle: .user,
                                            isShowingReportSheet: $isShowingReportSheet,
                                            isShowingBlockAlert: $isShowingBlockAlert,
                                            isShowingEllipsisSheet: $isShowingEllipsisSheet,
                                            isShowingDeleteAlert: .constant(false))
                        .presentationDetents([.height(250)])
                    }
                }
            }
            .onAppear {
                Task {
                    await loadUserInfo()
                }
                userInfoStore.observeUserFollowData(email: userInfo.email)
                isFollowing = userInfoStore.checkIfFollowing(targetUserEmail: userInfo.email)
            }
            .onDisappear {
                userInfoStore.removeListener()
            }
        }
    }
    
    // 유저 메모 및 칼럼 업데이트
    private func loadUserInfo() async {
        do {
            userMemos = try await memoStore.loadMemosByUserEmail(email: userInfo.email)
            userColumns = try await columnStore.loadColumnsByUserEmail(email: userInfo.email)
        } catch {
            print("Error loading memos or columns: \(error.localizedDescription)")
        }
    }
}

#Preview {
    UserProfileView(userInfo: UserInfo(uid: "test", email: "e.e@com", nickname: "피곤해",
                                       registrationDate: Date(),
                                       preferredCategories: [],
                                       profileImageName: "profileImage2",
                                       introduction: "자고 싶어요.",
                                       followers: [],
                                       followings: [],
                                       blocked: [],
                                       likesMemos: [],
                                       likesColumns: []))
    .environmentObject(MemoStore())
    .environmentObject(ColumnStore())
}
