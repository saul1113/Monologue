//
//  MyAccountPageView.swift
//  Monologue
//
//  Created by Hyojeong on 10/23/24.
//

import SwiftUI

struct MyAccountPageView: View {
    @Binding var userInfo: UserInfo
    
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    
    @State var selectedSegment: String = "메모"
    @State private var userMemos: [Memo] = [] // 사용자가 작성한 메모들
    @State private var userColumns: [Column] = [] // 사용자가 작성한 칼럼들
    @State var filters: [String]? = nil
    
    private let sharedImage: Image = Image(.appLogo)
    
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
                    
                    // MARK: - 프로필 편집, 프로필 공유
                    HStack {
                        NavigationLink {
                            ProfileEditView(userInfo: $userInfo)
                        } label: {
                            Text("프로필 편집")
                                .modifier(BorderedButtonStyle())
                            
                            ShareLink(
                                item: sharedImage,
                                preview: SharePreview(userInfo.nickname, image: sharedImage)
                            ) {
                                Text("프로필 공유")
                                    .modifier(BorderedButtonStyle())
                            }
                        }
                    }
                    .padding(.bottom, 25)
                    
                    // MARK: - 메모 및 칼럼 뷰
                    CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)
                        .padding(.horizontal, -16)
                    
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
                                ColumnView(filters: $filters, userColumns: userColumns)
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
                .padding(.horizontal, 16)
                .foregroundStyle(.accent)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // MARK: - Toolbar - (좌)로고, (우)알람, 설정
                ToolbarItem(placement: .topBarLeading) {
                    Text("모노로그")
                        .font(.custom("Eulyoo1945-SemiBold", size: 23))
                        .foregroundStyle(.accent)
                        .padding(.leading, 10)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NotificationView()
                    } label: {
                        Image(systemName: "bell")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingView()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                
            }
            .onAppear {
                Task {
                    await loadUserPosts()
                    if let updatedUserInfo = userInfoStore.userInfo {
                        userInfo = updatedUserInfo
                    }
                }
                userInfoStore.observeUserFollowData(email: userInfo.email)
            }
            .onDisappear {
                userInfoStore.removeListener()
            }
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
}

//#Preview {
//    MyAccountPageView(userInfo: <#UserInfo#>)
//}
