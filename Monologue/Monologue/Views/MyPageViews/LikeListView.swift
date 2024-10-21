//
//  LikeListView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct LikeListView: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedSegment: String = "메모"
    @State var filters: [String]? = nil
    @State private var likedMemos: [Memo] = [] // 사용자가 좋아요한 메모들
    @State private var likedColumns: [Column] = [] // 사용자가 좋아요한 칼럼들
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)
                    .padding(.horizontal, -16)
                
                // 버튼 & 스와이프 제스처 사용
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        if likedMemos.isEmpty {
                            Text("좋아요한 메모가 없습니다.")
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        } else {
                            MemoView(filters: $filters, userMemos: likedMemos)
                                .frame(width: geometry.size.width)
                        }
                        
                        if likedColumns.isEmpty {
                            Text("좋아요한 칼럼이 없습니다.")
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        } else {
                            ColumnView(filteredColumns: $likedColumns)
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
            }
            .foregroundStyle(.accent)
        }
        .navigationTitle("좋아요 목록")
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
        .onAppear {
            Task {
                await loadLikedContent()
            }
        }
    }
    
    private func loadLikedContent() async {
        do {
            if let userInfo = userInfoStore.userInfo {
                let likedMemoIds = userInfo.likesMemos
                let likedColumnIds = userInfo.likesColumns
                
                // 좋아요한 메모가 있을 경우에만 불러오기
                if !likedMemoIds.isEmpty {
                    likedMemos = try await memoStore.loadMemosByIds(ids: likedMemoIds)
                } else {
                    likedMemos = []
                }
                
                // 좋아요한 칼럼이 있을 경우에만 불러오기
                if !likedColumnIds.isEmpty {
                    likedColumns = try await columnStore.loadColumnsByIds(ids: likedColumnIds)
                } else {
                    likedColumns = []
                }
            }
        } catch {
            print("Error loading liked content: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        LikeListView()
    }
}
