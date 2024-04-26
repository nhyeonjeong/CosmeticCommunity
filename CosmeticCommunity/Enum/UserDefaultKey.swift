//
//  User.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import Foundation

enum UserDefaultKey {
    enum User: String {
        case accessToken
        case refreshToken
        case userId
        
        case profileImagePath
    }
    
    enum Post: String {
        case recentPosts
    }
}
