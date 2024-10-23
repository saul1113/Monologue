//
//  LinkPreview.swift
//  Monologue
//
//  Created by 강희창 on 10/22/24.
//

import SwiftUI
import LinkPresentation

// URL 미리보기를 위한 UIViewRepresentable
struct LinkPreviewView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> LPLinkView {
        let linkView = LPLinkView(url: url)
        let metadata = LPLinkMetadata()
        metadata.originalURL = url
        linkView.metadata = metadata
        return linkView
    }

    func updateUIView(_ uiView: LPLinkView, context: Context) {}
}

struct LinkPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        LinkPreviewView(url: URL(string: "https://likelion.net")!)
            .previewLayout(.sizeThatFits)
    }
}
