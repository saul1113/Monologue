//
//  SettingView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingAlert = false
    @EnvironmentObject var authManager: AuthManager
    
    // 앱 버전과 빌드 번호
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                List {
                    Section("사용자 설정") {
                        NavigationLink("좋아요 목록") {
                            LikeListView()
                        }
                        
                        NavigationLink("차단 유저 목록") {
                            BlockedUsersListView()
                        }
                        
                        Button("로그아웃") {
                            authManager.signOut()
                            
                            print(authManager.email)
                            // 파베 로그아웃 로직
                            print("로그아웃 성공")
                        }
                        
                        Button("계정 탈퇴") {
                            isShowingAlert.toggle()
                        }
                        .foregroundStyle(.red)
                        .alert("계정을 탈퇴합니다", isPresented: $isShowingAlert) {
                            Button("탈퇴", role: .destructive) {
                                // 파베 계정 탈퇴 로직
                            }
                        } message: {
                            Text("탈퇴 후 삭제되는 모든 정보는 복구할 수 없습니다.")
                        }
                    }
                    .listRowBackground(Color(.background))
                    
                    Section("기타") {
                        HStack {
                            Text("앱 버전")
                            
                            Spacer()
                            
                            Text(appVersion)
                                .bold()
                        }
                    }
                    .listRowBackground(Color(.background))
                }
                .listStyle(.plain)
            }
            .foregroundStyle(.accent)
        }
        .navigationTitle("설정")
        .toolbarTitleDisplayMode(.inline)
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
        SettingView()
            .environmentObject(AuthManager())
            .environmentObject(UserInfoStore())
            .environmentObject(MemoStore())
            .environmentObject(ColumnStore())
            .environmentObject(CommentStore())
    }
}
