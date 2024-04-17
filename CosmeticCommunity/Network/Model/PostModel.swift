//
//  PostQuery.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import Foundation

struct PostQuery: Encodable {
    let product_id: String // 게시판..
    let title: String // 제목
    let content: String // 내용
    let content1: String // 웜쿨
    let content2: String // 피부타입
    let files: [String]? // 사진을 안 올릴수도.,,
}

struct PostModel: Decodable {
    let product_id: String // 게시판..
    let title: String // 제목
    let content: String // 내용
    let content1: String? // 웜쿨
    let content2: String? // 피부타입
    let createdAt: String
    let creator: Creator
    let files: [String]
    let likes: [String]
    let hashTags: [String]
    let comments: [Comment]
}

struct Creator: Decodable {
    let user_id: String
    let nick: String
    let profileImage: String // 없으면 기본 이미지
    
    enum CodingKeys: CodingKey {
        case user_id
        case nick
        case profileImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? Constants.Image.defualtProfilePath
    }
}

struct Comment: Decodable {
    let comment_id: String
    let content: String
    let createdAt: String
    let creator: Creator
}
