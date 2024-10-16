//
//  MyPageView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager:AuthManager
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    
    @State var selectedSegment: String = "메모"
    @State private var userMemos: [Memo] = [] // 사용자가 작성한 메모들
    @State private var userColumns: [Column] = [] // 사용자가 작성한 칼럼들
    private var sharedString: String = "MONOLOG" // 변경 예정
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()
                
                VStack {
                    HStack(spacing: 20) {
                        Text("MONOLOG")
                            .foregroundStyle(.accent)
                            .font(.title3)
                            .bold()
                        
                        Spacer()
                        
                        NavigationLink {
                            Text("알림 페이지")
                        } label: {
                            Image(systemName: "bell")
                                .font(.title3)
                        }
                        
                        NavigationLink {
                            SettingView()
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.title3)
                        }
                    }
                    
                    // 프사, 닉, 상메
                    HStack {
                        // 프로필 사진
                        ProfileImageView(profileImageName: userInfoStore.userInfo?.profileImageName ?? "")
                            .padding(.trailing, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(userInfoStore.userInfo?.nickname ?? "닉네임 없음")
                                .font(.system(size: 18))
                                .bold()
                            
                            Text(userInfoStore.userInfo?.introduction ?? "자기소개가 없습니다.")
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
                            Text("\(userInfoStore.getMemoCount(userNickname: authManager.name))") // Memo 개수
                                .bold()
                        }
                        .padding(.horizontal, 2)
                        
                        Divider()
                        
                        HStack {
                            Text("칼럼")
                            Text("\(userInfoStore.getColumnCount(userNickname: authManager.name))") // Column 개수
                                .bold()
                        }
                        .padding(.horizontal, 2)
                        
                        Divider()
                        
                        NavigationLink {
                            FollowListView(selectedSegment: "팔로워")
                        } label: {
                            HStack {
                                Text("팔로워")
                                Text("\(userInfoStore.userInfo?.followers.count ?? 0)")
                                    .bold()
                            }
                            .padding(.horizontal, 2)
                        }
                        
                        Divider()
                        
                        NavigationLink {
                            FollowListView(selectedSegment: "팔로잉")
                        } label: {
                            HStack {
                                Text("팔로잉")
                                Text("\(userInfoStore.userInfo?.followings.count ?? 0)")
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
                        NavigationLink {
                            ProfileEditView()
                        } label: {
                            Text("프로필 편집")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, minHeight: 30)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.accent, lineWidth: 1)
                                )
                        }
                        
                        ShareLink(item: sharedString) {
                            Text("프로필 공유")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, minHeight: 30)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.accent, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.bottom, 30)
                    
                    CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)
                    
                    if selectedSegment == "메모" {
                        // 메모 뷰
                        MemoView(filteredMemos: userMemos)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else if selectedSegment == "칼럼" {
                        // 칼럼 뷰
                        ColumnView(filteredColumns: userColumns)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                .foregroundStyle(.accent)
            }
            .onAppear {
                Task {
                    // 유저의 정보 로드
                    await userInfoStore.loadUserInfo(email: authManager.email)
                    
                    // 유저의 메모 로드
                    memoStore.loadMemosByUserNickname(userNickname: authManager.name) { memos, error in
                        if let memos = memos {
                            userMemos = memos
                        }
                    }
                    
                    // 유저의 칼럼 로드
                    columnStore.loadColumnsByUserNickname(userNickname: authManager.name) { columns, error in
                        if let columns = columns {
                            userColumns = columns
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    NavigationStack {
//        MyPageView()
//            .environmentObject(AuthManager())
//            .environmentObject(UserInfoStore())
//            .environmentObject(MemoStore())
//            .environmentObject(ColumnStore())
//    }
//}
