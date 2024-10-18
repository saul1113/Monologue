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
    
    @State var filters: [String]? = nil
    
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
                            NotificationView()
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
                        ProfileImageView(profileImageName: userInfoStore.userInfo?.profileImageName ?? "",
                                         size: 77)
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
                            Text("\(userMemos.count)") // Memo 개수
                                .bold()
                        }
                        .padding(.horizontal, 2)
                        
                        Divider()
                        
                        HStack {
                            Text("칼럼")
                            Text("\(userColumns.count)") // Column 개수
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
                    
                    // 버튼 & 스와이프 제스처 사용
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            MemoView(filters: $filters, userMemos: userMemos)
                                .frame(width: geometry.size.width)

                            ColumnView(filteredColumns: userColumns)
                                .frame(width: geometry.size.width)
                        }
                        .offset(x: selectedSegment == "메모" ? 0 : -geometry.size.width)
                        .animation(.easeInOut, value: selectedSegment)
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width > 100 {
                                        selectedSegment = "메모"
                                    } else if value.translation.width < -100 {
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
            .onAppear {
                Task {
                    // 사용자 인증 상태가 인증 완료 상태인 경우에만 Firestore 데이터 로드
                    if authManager.authenticationState == .authenticated {
                        // 유저의 정보 로드
                         await loadUserContent()
                    }
                }
            }
        }
    }
    
    // 유저 정보, 메모, 칼럼 로드 함수
    private func loadUserContent() async {
        do {
            await userInfoStore.loadUserInfo(email: authManager.email)
            
            if let nickname = userInfoStore.userInfo?.nickname {
                userMemos = try await memoStore.loadMemosByUserNickname(userNickname: nickname)
                userColumns = try await columnStore.loadColumnsByUserNickname(userNickname: nickname)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
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
