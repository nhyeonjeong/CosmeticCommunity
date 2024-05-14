//
//  PaymentModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/14.
//

import Foundation

struct PaymentQuery: Encodable {
    let impId: String
    let postId: String
    let productName: String
    let price: Int
    enum CodingKeys: String, CodingKey {
        case impId = "imp_uid"
        case postId = "post_id"
        case productName
        case price
    }
}
