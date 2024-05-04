//
//  UserQueryModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import Foundation

// Encodable
struct LoginQuery: Encodable {
    let email: String
    let password: String
}

struct JoinQuery: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String
    let birthDay: String
}
struct ValidEmailQuery: Encodable {
    let email: String
}

// Decodable
struct LoginModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let profileImage: String // 프로필이 없을수도 있음 -> 없으면 무조건 기본 이미지
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: CodingKey {
        case user_id
        case email
        case nick
        case profileImage
        case accessToken
        case refreshToken
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.email = try container.decode(String.self, forKey: .email)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? Constants.Image.defualtProfilePath // 기본 이미지
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
}

struct UserModel: Decodable {
    let user_id: String
    let nick: String
    let personalColor: PersonalColor // 상대방프로필에는 없다.
    let profileImage: String
    let followers: [CreatorModel]
    let following: [CreatorModel]
    let posts: [String]
    
    enum CodingKeys: CodingKey {
        case user_id
        case nick
        case birthDay
        case profileImage
        case followers
        case following
        case posts
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user_id = try container.decode(String.self, forKey: .user_id)
        self.nick = try container.decode(String.self, forKey: .nick)

        let personalColorString = try container.decodeIfPresent(String.self, forKey: .birthDay) ?? PersonalColor.none.rawValue
        self.personalColor = PersonalColor(rawValue: personalColorString) ?? PersonalColor.none
        
        self.profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage) ?? Constants.Image.defualtProfilePath
        self.followers = try container.decode([CreatorModel].self, forKey: .followers)
        self.following = try container.decode([CreatorModel].self, forKey: .following)
        self.posts = try container.decode([String].self, forKey: .posts)
    }
}

struct CreatorModel: Decodable {
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

struct ValidMessageModel: Decodable {
    let message: String
}
