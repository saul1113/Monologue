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
    
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    
    @Environment(\.dismiss) private var dismiss
    @State var selectedSegment: String = "메모"
    @State private var userMemos: [Memo] = [] // 사용자가 작성한 메모들
    @State private var userColumns: [Column] = [] // 사용자가 작성한 칼럼들
    @State private var isShowingSheet: Bool = false
    
    private var sharedString: String = "MONOLOG" // 변경 예정
    
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
                                Text("\(userInfo.followers.count)")
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
                                Text("\(userInfo.followings.count)")
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
                            // 팔로 or 언팔 로직
                        } label: {
                            Text("팔로잉") // 팔로우 상태에 따라 텍스트 변경하도록 바꿔야 됨...
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, minHeight: 30)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.accent, lineWidth: 1)
                                )
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
                    
                    if selectedSegment == "메모" {
                        // 메모 뷰
                        MemoView(filters: $filters, userMemos: userMemos)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, -16)
                        
                    } else if selectedSegment == "칼럼" {
                        // 칼럼 뷰
                        ColumnView(filteredColumns: userColumns)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, -16)
                    }
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
                        isShowingSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                    }
                    .confirmationDialog("", isPresented: $isShowingSheet) {
                        Button("공유하기") {
                            
                        }
                        
                        Button("차단하기", role: .destructive) {
                            
                        }
                        
                        Button("신고하기", role: .destructive) {
                            
                        }
                        
                        Button("취소", role: .cancel) {}
                    }
                }
            }
            .onAppear {
                Task {
                    await loadUserInfo()
                }
            }
        }
    }
    
    // 유저 메모 및 칼럼 업데이트
    private func loadUserInfo() async {
        do {
            userMemos = try await memoStore.loadMemosByUserNickname(userNickname: userInfo.nickname)
            userColumns = try await columnStore.loadColumnsByUserNickname(userNickname: userInfo.nickname)
        } catch {
            print("Error loading memos or columns: \(error.localizedDescription)")
        }
    }
}

#Preview {
    UserProfileView(userInfo: UserInfo(nickname: "피곤해",
                                       registrationDate: Date(),
                                       preferredCategories: [],
                                       profileImageName: "profileImage2",
                                       introduction: "자고 싶어요.",
                                       followers: [],
                                       followings: [],
                                       blocked: [],
                                       likes: []))
}
