//
//  FilterButtons.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import SwiftUI
import OrderedCollections

@ViewBuilder
func categoryView(dict: Binding<OrderedDictionary<String, Bool>>) -> some View {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack {
            ForEach(dict.wrappedValue.elements.indices, id: \.self) { index in
                Button {
                    if index == 0 {
                        for innerIndex in 1..<dict.wrappedValue.elements.count {
                            dict.wrappedValue[dict.wrappedValue.elements[innerIndex].key]? = false
                        }
                        dict.wrappedValue[dict.wrappedValue.elements[index].key]?.toggle()
                    } else {
                        if dict.wrappedValue[dict.wrappedValue.elements[0].key]! {
                            dict.wrappedValue[dict.wrappedValue.elements[0].key]? = false
                        }
                        
                        if let firstValue = dict.wrappedValue[dict.wrappedValue.elements[0].key], !firstValue {
                            dict.wrappedValue[dict.wrappedValue.elements[index].key]?.toggle()
                        }
                    }
                } label: {
                    Text(dict.wrappedValue.elements[index].key)
                        .foregroundStyle(dict.wrappedValue.elements[index].value ? .white : .accent)
                        .padding([.leading, .trailing], 15)
                        .padding([.top, .bottom], 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(dict.wrappedValue.elements[index].value ? .accent : .white)
                                .stroke(.accent.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.trailing, 10)
            }
        }
        .frame(minHeight: 50)
        .padding(.leading, 16)
    }
}
