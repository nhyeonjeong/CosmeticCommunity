//
//  CommentModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import Foundation

struct CommentQuery: Encodable {
    let content: String
}

struct CommentModel: Decodable {
    let comment_id: String
    let content: String
    let createdAt: String
    let creator: CreatorModel
}
