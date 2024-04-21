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
    case uploadPostImage(query: [Data]?)
    case upload(query: PostQuery)
    case checkPosts(query: CheckPostQuery)
    case checkSpecificPost(postId: String)
    // Commmet
    case likeStatus(query: CommentQuery, postId: String)
    // Follow
    
    // Hashtag
    
    // Image
//    case getImage(query: [String])
}

extension Router: RouterType {
    var baseURL: String {
        return APIKey.baseURL.rawValue
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .join, .uploadPostImage, .upload, .likeStatus:
            return .post
        case .tokenRefresh, .checkPosts, .checkSpecificPost:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        print("----network---", self.path, "headersAccessToken", MemberManger.shared.getAccessToken())
        switch self {
        case .tokenRefresh:
            return [HTTPHeader.authorization.rawValue: MemberManger.shared.getAccessToken() ?? "",
                    HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                    HTTPHeader.refreshToken.rawValue: MemberManger.shared.getRefreshToken() ?? ""] // refreshToken도 들어가야함
        case .login, .join:
            return [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        case  .upload, .likeStatus:
            return [HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                    HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                    HTTPHeader.authorization.rawValue: MemberManger.shared.getAccessToken() ?? ""]
        case .uploadPostImage:
            return [HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                    HTTPHeader.contentType.rawValue: HTTPHeader.multipartData.rawValue,
                    HTTPHeader.authorization.rawValue: MemberManger.shared.getAccessToken() ?? ""]
        case .checkPosts, .checkSpecificPost:
            return [ HTTPHeader.authorization.rawValue: MemberManger.shared.getAccessToken() ?? "",
                     HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
            
        }
    }
    
    var path: String {
        switch self {
        case .tokenRefresh:
            return "v1/auth/refresh"
        case .login:
            return "v1/users/login"
        case .join:
            return "v1/users/join"
        case .uploadPostImage:
            return "v1/posts/files"
        case .upload, .checkPosts:
            return "v1/posts"
        case .checkSpecificPost(let postId):
            return "v1/posts/\(postId)"
        case .likeStatus(_, let postId):
            return "v1/posts/\(postId)/like"
        }
    }
    var parameters: Parameters? {
        switch self {
        case .login(let query):
            return [ParameterKey.email.rawValue: query.email,
                    ParameterKey.password.rawValue: query.password]
        case .upload(let query):
            return [ParameterKey.product_id.rawValue: query.product_id,
                    ParameterKey.title.rawValue: query.title,
                    ParameterKey.content.rawValue: query.content,
                    ParameterKey.content1.rawValue: query.content1,
                    ParameterKey.files.rawValue: query.files]
        case .likeStatus(let query, _):
            return [ParameterKey.like_status.rawValue: query.like_status]
        case .join, .tokenRefresh, .uploadPostImage, .checkPosts, .checkSpecificPost:
            return nil
        }
    }
    
    var queryItem: [URLQueryItem]? {
        switch self {
        case .checkPosts(let query):
            return [URLQueryItem(name: QueryKey.next.rawValue, value: query.next),
                    URLQueryItem(name: QueryKey.limit.rawValue, value: query.limit),
                    URLQueryItem(name: QueryKey.product_id.rawValue, value: query.product_id)]
        case .login, .join, .upload, .tokenRefresh, .uploadPostImage, .checkSpecificPost, .likeStatus:
            return nil
        }
    }
    
    var body: Data? {
        switch self {
        case .tokenRefresh:
            return nil
        case .login(let query):
            return jsonEncoding(query)
        case .join(let query):
            return jsonEncoding(query)
        case .upload(let query):
            return jsonEncoding(query)
        case .likeStatus(let query, _):
            return jsonEncoding(query)
        case .uploadPostImage, .checkPosts, .checkSpecificPost:
            return nil
        }
    }
        
    var multipartBody: [Data]? {
        switch self {
        case .tokenRefresh, .login, .join, .upload, .checkPosts, .checkSpecificPost, .likeStatus:
            return nil
        case .uploadPostImage(let query):
            return query
        }
    }
}

extension Router {
    func jsonEncoding<T: Encodable>(_ query: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try? encoder.encode(query)
    }
}

