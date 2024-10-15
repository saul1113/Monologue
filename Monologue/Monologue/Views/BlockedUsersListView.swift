//
//  BlockedUsersListView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct BlockedUsersListView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            ScrollView {
                // ForEach로 변경 예정
                VStack {
                    BlockedUserRow(profileImageName: "", nickname: "북극성", memoCount: 3, columnCount: 5)
                    BlockedUserRow(profileImageName: "", nickname: "북극성", memoCount: 3, columnCount: 5)
                    BlockedUserRow(profileImageName: "", nickname: "북극성", memoCount: 3, columnCount: 5)
                    BlockedUserRow(profileImageName: "", nickname: "북극성", memoCount: 3, columnCount: 5)
                    BlockedUserRow(profileImageName: "", nickname: "북극성", memoCount: 3, columnCount: 5)
                    BlockedUserRow(profileImageName: "", nickname: "북극성", memoCount: 3, columnCount: 5)
                    BlockedUserRow(profileImageName: "", nickname: "북극성", memoCount: 3, columnCount: 5)
                }
                .padding(.top, 25)
                .padding(.horizontal, 16)
                .foregroundStyle(.accent)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationTitle("차단 유저 목록")
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
        BlockedUsersListView()
    }
}
