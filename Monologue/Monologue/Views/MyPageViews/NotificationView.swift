//
//  NotificationView.swift
//  Monologue
//
//  Created by Hyojeong on 10/17/24.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            Text("알림 페이지")
        }
        .navigationTitle("알림")
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
    NotificationView()
}
