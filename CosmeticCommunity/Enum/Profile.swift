//
//  Profile.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/23.
//

import Foundation

enum MyProfile: Int, ProfileProtocol {
    case followers = 0
    case following
    case likePosts
    var buttonLabel: String? {
        switch self {
        case .followers: return FollowType.followers.rawValue
        case .following: return FollowType.following.rawValue
        case .likePosts: return nil
        }
    }
}

enum OtherProfile: Int, ProfileProtocol {
    case followers = 0
    case following
    var buttonLabel: String? {
        switch self {
        case .followers: return FollowType.followers.rawValue
        case .following: return FollowType.following.rawValue
        }
    }
}

enum FollowType: String {
    case followers = "팔로워"
    case following = "팔로잉"
}
