//
//  MyPageView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    var sharedString: String = "MONOLOG" // 변경 예정
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()
                
                VStack {
                    // 프사, 닉, 상메
                    HStack {
                        // 프로필 사진
                        Circle() // profileImageName
                            .frame(width: 77, height: 77)
                            .padding(.trailing, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("북극성") // nickname
                                .font(.system(size: 18))
                                .bold()
                            
                            Text("IT와 관련된 글을 쓰는 북극성입니다.") // introduction
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
                            Text("\(4)") // Memo 개수
                                .bold()
                        }
                        .padding(.horizontal, 2)
                        
                        Divider()
                        
                        HStack {
                            Text("칼럼")
                            Text("\(4)") // Column 개수
                                .bold()
                        }
                        .padding(.horizontal, 2)
                        
                        Divider()
                        
                        NavigationLink {
                            FollowListView(selectedSegment: "팔로워")
                        } label: {
                            HStack {
                                Text("팔로워")
                                Text("\(4)") // following.count
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
                                Text("\(4)") // follower.count
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
                    
                    // 메모, 칼럼 뷰 얹을 예정
                    Spacer()
                }
                .padding(.horizontal, 16)
                .foregroundStyle(.accent)
                
            }
            .toolbar {
                // 로고
                ToolbarItem(placement: .topBarLeading) {
                    Text("MONOLOG")
                        .foregroundStyle(.accent)
                        .font(.title3)
                        .bold()
                }
                
                // 알림 버튼
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        // 알림 페이지
                    } label: {
                        Image(systemName: "bell")
                    }
                }
                
                // 설정 버튼
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingView()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyPageView()
    }
}
