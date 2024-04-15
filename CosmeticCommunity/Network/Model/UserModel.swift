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

// Decodable
struct RefreshTokenModel: Decodable {
    let accessToken: String
}

struct LoginModel: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}
