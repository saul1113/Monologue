//
//  MansoryLayout.swift
//  Monologue
//
//  Created by 홍지수 on 10/15/24.
//

import SwiftUI

struct MasonryLayout: Layout {
    let columns: Int
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // 각 컬럼의 너비 계산
        let columnWidth = (proposal.width ?? 0 - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        // 각 컬럼의 현재 높이를 저장할 배열
        var columnHeights = Array(repeating: CGFloat(0), count: columns)

        // 서브뷰를 순회하며 컬럼에 배치
        for subview in subviews {
            // 현재 가장 낮은 컬럼을 찾음
            let index = columnHeights.firstIndex(of: columnHeights.min() ?? 0) ?? 0
            // 서브뷰의 크기를 계산
            let size = subview.sizeThatFits(
                ProposedViewSize(width: columnWidth, height: nil)
            )
            // 해당 컬럼의 높이를 업데이트
            columnHeights[index] += size.height + spacing
        }

        // 전체 높이는 가장 높은 컬럼의 높이
        let height = columnHeights.max() ?? 0
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columnWidth = (bounds.width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
        var columnHeights = Array(repeating: CGFloat(0), count: columns)

        for subview in subviews {
            let index = columnHeights.firstIndex(of: columnHeights.min() ?? 0) ?? 0
            let x = bounds.minX + CGFloat(index) * (columnWidth + spacing)
            let y = bounds.minY + columnHeights[index]
            let size = subview.sizeThatFits(
                ProposedViewSize(width: columnWidth, height: nil)
            )

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: columnWidth, height: size.height)
            )

            columnHeights[index] += size.height + spacing
        }
    }
}
