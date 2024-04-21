//
//  PostQuery.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import Foundation

struct CheckPostQuery {
    let next: String?
    let limit: String = "20"
    let product_id: String?
}

struct PostQuery: Encodable {
    let product_id: String // 게시판..
    let title: String // 제목
    let content: String // 내용
    let content1: String // 웜쿨
    let files: [String] // 사진을 안 올릴수도.,,
}

struct CheckPostModel: Decodable {
    let data: [PostModel]
    let next_cursor: String
}
struct PostImageStingModel: Decodable {
    let files: [String]
}

struct PostModel: Decodable {
    let post_id: String
    let product_id: String // 게시판..
    let title: String // 제목
    let content: String // 내용
    let content1: String? // 웜쿨
    let createdAt: String
    let creator: CreatorModel
    let files: [String]
    let likes: [String]
    let hashTags: [String]
    let comments: [CommentModel]
}



