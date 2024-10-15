//
//  FollowListView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct FollowListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isActionActive = true // 팔로우 상태 관리
    
    @State var selectedSegment: String // 마이페이지뷰에서 받음
    private let segments = ["팔로워", "팔로잉"] // 세그먼트 버튼
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            // 커스텀 Segment
            GeometryReader { geometry in
                HStack {
                    ForEach(segments, id: \.self) { segment in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedSegment = segment
                            }
                        } label: {
                            Text(segment)
                                .font(.system(size: 16))
                                .foregroundStyle(.accent)
                                .frame(maxWidth: .infinity) // 각 탭을 동일한 너비로 설정
                        }
                    }
                }
                .overlay(
                    // 전체 너비 밑줄
                    Rectangle()
                        .fill(.accent.opacity(0.2))
                        .frame(width: geometry.size.width, height: 1) // 전체 너비
                        .offset(y: 13),
                    alignment: .bottomLeading
                )
                .overlay(
                    Rectangle()
                        .fill(.accent)
                        .frame(width: geometry.size.width / 2, height: 2)
                        .offset(x: selectedSegment == "팔로워" ? 0 : geometry.size.width / 2, y: 13),
                    alignment: .bottomLeading
                )
            }
            
            ScrollView {
                VStack {
                    if selectedSegment == "팔로워" {
                        // 팔로워 뷰
                        ForEach($users) { $user in
                            UserRow(
                                profileImageName: user.profileImageName,
                                nickname: user.nickname,
                                memoCount: user.memoCount,
                                columnCount: user.columnCount,
                                isActionActive: $user.isActionActive, // 개별 상태 관리
                                activeButtonText: "팔로우",
                                inactiveButtonText: "팔로잉",
                                onActive: {
                                    // 팔로우 로직
                                    print("\(user.nickname) 다시 팔로우")
                                },
                                onInactive: {
                                    // 언팔로우 로직
                                    print("\(user.nickname) 언팔")
                                }
                            )
                        }
                    } else {
                        // 팔로잉 뷰
                        ForEach($users) { $user in
                            UserRow(
                                profileImageName: user.profileImageName,
                                nickname: user.nickname,
                                memoCount: user.memoCount,
                                columnCount: user.columnCount,
                                isActionActive: $user.isActionActive, // 개별 상태 관리
                                activeButtonText: "팔로우",
                                inactiveButtonText: "팔로잉",
                                onActive: {
                                    // 팔로우 로직
                                    print("\(user.nickname) 다시 팔로우")
                                },
                                onInactive: {
                                    // 언팔로우 로직
                                    print("\(user.nickname) 언팔")
                                }
                            )
                        }
                    }
                }
                .foregroundStyle(.accent)
                .padding(.horizontal, 16)
            }
            .padding(.top, 60)
        }
        .navigationTitle("북극성") // nickname 데이터로 변경 예정
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
    }
}

#Preview {
    NavigationStack {
        FollowListView(selectedSegment: "팔로워")
    }
}
