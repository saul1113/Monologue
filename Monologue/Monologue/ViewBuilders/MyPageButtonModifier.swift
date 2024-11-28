//
//  MyPageButtonModifier.swift
//  Monologue
//
//  Created by Hyojeong on 10/22/24.
//

import SwiftUI

struct BorderedButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15))
            .frame(maxWidth: .infinity, minHeight: 30)
            .background(RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.accent, lineWidth: 1)
            )
    }
}

struct FilledButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15))
            .frame(maxWidth: .infinity, minHeight: 30)
            .foregroundStyle(.white)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(.accent))
    }
}
