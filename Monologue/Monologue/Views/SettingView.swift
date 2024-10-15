//
//  SettingView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                List {
                    Section("사용자 설정") {
                        NavigationLink("좋아요 목록") {
                            
                        }
                        
                        NavigationLink("차단 유저 목록") {
                            
                        }
                        
                        Button("로그아웃") {
                            // 파베 로직
                            print("로그아웃")
                        }
                        
                        Button("계정 탈퇴") {
                            // 파베 로직
                            print("계정 탈퇴")
                        }
                        .foregroundStyle(.red)
                    }
                    .listRowBackground(Color(.background))
                    
                    Section("기타") {
                        HStack {
                            Text("앱 버전")
                            
                            Spacer()
                            
                            Text("1.0")
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
    }
}
