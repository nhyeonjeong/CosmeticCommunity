//
//  Network.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import Foundation

enum HTTPHeader: String {
    case authorization = "Authorization" // 액세스 토큰
    case sesacKey = "SesacKey"
    case refreshToken = "Refresh"
    case contentType = "Content-Type"
    case json = "application/json"
    case multipartData = "multipart/form-data"
}
