//
//  Router.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import Foundation
import Alamofire

enum Router {
    // Member
    case tokenRefresh
    case login(query: LoginQuery)
    case join(query: JoinQuery)
//    case validEmail
//    case withdraw
    //Profile
    
    // Post
    case upload(query: PostQuery, accessToken: String)
    // Commmet
    
    // Follow
    
    // Hashtag
}

extension Router: RouterType {
    var baseURL: String {
        return APIKey.baseURL.rawValue
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .join, .upload:
            return .post
        case .tokenRefresh:
            return .get
        }
    }
    
    var header: HTTPHeaders {
        switch self {
        case .tokenRefresh:
            return [HTTPHeader.authorization.rawValue: MemberManger.shared.getAccessToken() ?? "",
                HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                    HTTPHeader.refreshToken.rawValue: MemberManger.shared.getRefreshToken() ?? ""] // refreshToken도 들어가야함
        case .login, .join:
            return [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
            
        case .upload(_, let accessToken):
            return [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                    HTTPHeader.authorization.rawValue: accessToken,
                    HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
            
        }
    }
    
    var path: String {
        switch self {
        case .tokenRefresh:
            return "\(baseURL)/v1/auth/refresh"
        case .login:
            return "\(baseURL)/v1/users/login"
        case .join:
            return "\(baseURL)/v1/users/join"
        case .upload:
            return "\(baseURL)/v1/posts"
        }
    }
    
    var parameters: [String: Encodable]? {
        switch self {
        case .login(let query):
            return [ParameterKey.email.rawValue: query.email,
                    ParameterKey.password.rawValue: query.password]
        case .join, .tokenRefresh:
            return nil
        case .upload(let query, _):
            return [ParameterKey.product_id.rawValue: query.product_id,
                    ParameterKey.title.rawValue: query.title,
                    ParameterKey.content.rawValue: query.content,
                    ParameterKey.content1.rawValue: query.content1,
                    ParameterKey.content2.rawValue: query.content2,
                    ParameterKey.files.rawValue: query.files ?? []]
 
        }
    }
    
    var queryItem: [URLQueryItem]? {
        switch self {
        case .login, .join, .upload, .tokenRefresh:
            return nil
        }
        /*
        switch self {
        case .trending:
            ["": ""] // 빈 거 보내는 것도 가능
        case .search(let query):
            ["language": "ko-KR", "query": query]
        case .photo:
            ["":""] // 여기도 딱히 queryString없음
        }
         */
    }
    
    var body: Data? {
        switch self {
        case .tokenRefresh:
            return nil
        case .login(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .join(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .upload(let query, _):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        }
    }
    
}
