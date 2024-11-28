//
//  CustomSegmentView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct CustomSegmentView: View {
    let segment1: String
    let segment2: String
    @Binding var selectedSegment: String // 선택된 세그먼트
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                // 첫 번째 세그먼트
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedSegment = segment1
                    }
                } label: {
                    Text(segment1)
                        .font(.system(size: 16))
                        .foregroundStyle(.accent)
                        .frame(maxWidth: .infinity)
                }
                
                // 두 번째 세그먼트
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedSegment = segment2
                    }
                } label: {
                    Text(segment2)
                        .font(.system(size: 16))
                        .foregroundStyle(.accent)
                        .frame(maxWidth: .infinity)
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
                    .offset(x: selectedSegment == segment1 ? 0 : geometry.size.width / 2, y: 13),
                alignment: .bottomLeading
            )
        }
        .frame(height: 40)
    }
}
