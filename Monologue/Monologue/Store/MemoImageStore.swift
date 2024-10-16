//
//  MemoImageStore.swift
//  Monologue
//
//  Created by 김종혁 on 10/16/24.
//

import Foundation
import FirebaseStorage
import SwiftUI

class MemoImageStore: ObservableObject {
    @Published var images: [UIImage] = [] // 이미지 이름이 추적이 안됨 -> index로 매칭을 했다.
    
    // 스토리지에 이미지 파일
    func UploadImage(image: UIImage ,imageName: String) {
        let uploadRef = Storage.storage().reference(withPath: "img/\(imageName)")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let uploadMetaData = StorageMetadata.init()
        uploadMetaData.contentType = "image/jpeg"
        
        uploadRef.putData(imageData, metadata: uploadMetaData) { (downloadMetaData, error) in
            if let error = error {
                print("Error! \(error.localizedDescription)")
                return
            }
            print("complete: \(String(describing: downloadMetaData))")
        }
    }
    
    func loadImage(imageName: String, completion: @escaping (UIImage?) -> Void) {
        let storagRef = Storage.storage().reference(withPath: "img/\(imageName)")
        storagRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("에러 발생: \(error.localizedDescription)")
                completion(nil) // 에러 발생 시 nil 반환
                return
            }
            guard let tempImage = UIImage(data: data!) else {
                completion(nil) // 이미지 변환 실패 시 nil 반환
                return
            }
            
            self.images.append(tempImage)
            print(tempImage)
            
            completion(tempImage) // 성공적으로 로드된 이미지 반환
        }
    }
}

// 메모 글 쓰기 -> 이미지 생성 -> 이미지 받아서 저장 -> 메인뷰나 내정보뷰에서 부를때 로드해서 이미지 배열에 담기
