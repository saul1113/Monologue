//
//  MyPageView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct MyPageView: View {
    @State var userInfo: UserInfo
    
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    
    @Environment(\.dismiss) private var dismiss
    
    // 내 계정 여부 확인
    private var isMyAccount: Bool {
        return authManager.email == userInfo.email
    }
    
    var body: some View {
        if isMyAccount {
            MyAccountPageView(userInfo: $userInfo)
        } else {
            OtherUserPageView(userInfo: $userInfo)
        }
    }
}
