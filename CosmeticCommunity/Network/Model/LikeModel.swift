//
//  CommentModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import Foundation

struct LikeQuery: Encodable {
    let like_status: Bool
}

struct LikeModel: Decodable {
    let like_status: Bool
}
