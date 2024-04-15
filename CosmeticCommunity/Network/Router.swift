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
    case login(query: LoginQuery)
    case join(query: JoinQuery)
//    case validEmail
//    case withdraw
    //Profile
    
    // Post
    
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
        case .login, .join:
            return .post
        }
    }
    
    var header: [String : String] {
        switch self {
        case .login, .join:
            return [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/v1/users/login"
        case .join:
            return "/v1/users/join"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .login(let query):
            return [ParameterKey.email.rawValue: query.email,
                    ParameterKey.password.rawValue: query.password]
        case .join:
            return nil
        }
    }
    
    var queryItem: [URLQueryItem]? {
        switch self {
        case .login, .join:
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
        case .login(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        case .join(let query):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return try? encoder.encode(query)
        }
    }
    
}
