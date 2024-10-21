//
//  MemoView.swift
//  Monologue
//
//  Created by 홍지수 on 10/15/24.
//

import SwiftUI
import OrderedCollections

class FilteredMemoStore: ObservableObject {
    private var memoStore: MemoStore = .init()
    private var memoImageStore: MemoImageStore = .init()
    
    @Published var filteredMemos: [Memo] = []
    @Published var images: [UIImage] = []
    @Published var isLoadingImages: Bool = false
    
    func setFilteredMemos(filters: [String]) {
        if filters == ["전체"] {
            Task {
                do {
                    let memos = try await memoStore.loadMemos()
                    
                    DispatchQueue.main.async {
                        self.filteredMemos = memos
                        self.loadImagesForMemos()
                    }
                } catch {
                    print("loadMemos error: \(error)")
                }
            }
        } else {
            Task {
                do {
                    let memos = try await memoStore.loadMemos().filter { memo in
                        memo.categories.contains { filters.contains($0) }
                    }
                    DispatchQueue.main.async {
                        self.filteredMemos = memos
                        self.loadImagesForMemos()
                    }
                } catch {
                    print("loadMemos error: \(error)")
                }
            }
        }
    }
    
    private func loadImagesForMemos() {
        DispatchQueue.main.async {
            self.images = []
            for memo in self.filteredMemos {
                self.memoImageStore.loadImage(imageName: memo.id) { image in
                    if let image = image {
                        self.images.append(image)
                    }
                }
            }
        }
    }
    
    func setUserMemos(userMemos: [Memo]) {
        DispatchQueue.main.async {
            self.filteredMemos = userMemos
            self.loadImagesForMemos()
        }
    }
}

struct MemoView: View {
    @StateObject private var filteredMemoStore: FilteredMemoStore = .init()
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @Binding var filters: [String]?
    var userMemos: [Memo]?
    var mode: MemoViewMode // Added mode for view differentiation
    
    var body: some View {
        ScrollView {
            MasonryLayout(columns: 2, spacing: 16) {
                if (filteredMemoStore.images.count != 0) && (filteredMemoStore.images.count == filteredMemoStore.filteredMemos.count) {
                    ForEach(filteredMemoStore.filteredMemos.indices, id: \.self) { index in
                        NavigationLink(destination: MemoDetailView(memo: $filteredMemoStore.filteredMemos[index], image: $filteredMemoStore.images[index])) {
                            ZStack {
                                (mode == .home && userInfoStore.userInfo?.nickname != filteredMemoStore.filteredMemos[index].userNickname) || mode == .myPage ?
                                VStack(alignment: .trailing) {
                                    let image = filteredMemoStore.images[index]
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width / 2 - 24, height: nil)
                                        .clipped()
                                        .cornerRadius(12)
                                        .scaledToFit()
                                    Text("\(filteredMemoStore.filteredMemos[index].userNickname)")
                                        .font(.caption2)
                                        .padding(.trailing, 8)
                                }
                                : nil
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            if let tempFilters = filters {
                filteredMemoStore.setFilteredMemos(filters: tempFilters)
            }
            
            if let userMemos = userMemos {
                filteredMemoStore.setUserMemos(userMemos: userMemos)
            }
        }
        .onChange(of: filters) {
            print("필터 : \(String(describing: filters))")
            if let tempFilters = filters {
                filteredMemoStore.setFilteredMemos(filters: tempFilters)
            }
        }
        .onChange(of: userMemos) {
            if let userMemos = userMemos {
                filteredMemoStore.setUserMemos(userMemos: userMemos)
            }
        }
    }
}
