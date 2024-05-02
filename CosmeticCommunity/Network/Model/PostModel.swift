//
//  PostQuery.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import Foundation
// 포스트 조회
struct CheckPostQuery {
    let next: String?
    var limit: String = "16"
    let product_id: String?
}
// 해시태그 검색
struct HashtagQuery {
    let next: String?
    let limit: String
    let product_id: String?
    let hashTag: String
}

struct PostQuery: Encodable {
    var product_id: String? // 게시판..
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
    let personalColor: PersonalColor // 웜쿨
    let createdAt: String
    let creator: CreatorModel
    let files: [String]
    let likes: [String]
    let hashTags: [String]
    let comments: [CommentModel]
    enum CodingKeys: CodingKey {
        case post_id
        case product_id
        case title
        case content
        case content1
        case createdAt
        case creator
        case files
        case likes
        case hashTags
        case comments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.post_id = try container.decode(String.self, forKey: .post_id)
        self.product_id = try container.decode(String.self, forKey: .product_id)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        let personalColorString = try container.decodeIfPresent(String.self, forKey: .content1) ?? PersonalColor.none.rawValue
        self.personalColor = PersonalColor(rawValue: personalColorString) ?? PersonalColor.none
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.creator = try container.decode(CreatorModel.self, forKey: .creator)
        self.files = try container.decode([String].self, forKey: .files)
        self.likes = try container.decode([String].self, forKey: .likes)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        self.comments = try container.decode([CommentModel].self, forKey: .comments)
    }
}



