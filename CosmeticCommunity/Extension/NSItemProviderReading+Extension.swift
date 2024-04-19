//
//  ItemProvider+Extension.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/19.
//

import UIKit

extension NSItemProviderReading {
    func changeToData() -> Data {
        if let photo = self as? UIImage, let data = photo.pngData() {
                return data
        }
        print("이미지 Data변화 실패")
        return Data()
    }
}
