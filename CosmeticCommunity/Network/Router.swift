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
    case myProfile
    case otherProfile(userId: String)
    // Post
    case uploadPostImage(query: [Data]?)
    case upload(query: PostQuery)
    case checkPosts(query: CheckPostQuery)
    case checkSpecificPost(postId: String)
    case checkUserPosts(userId: String)
    case deletePost(postId: String)
    // Likst
    case likeStatus(query: LikeQuery, postId: String)
    case myLikedPosts
    // Commmet
    case uploadComment(query: CommentQuery, postId: String)
    case deleteComment(postId: String, commentId: String)
    // Follow
    
    // Hashtag
    case hashtag(query: HashtagQuery)
    // Image
    //    case getImage(query: [String])
}

extension Router: RouterType {
    var baseURL: String {
        return APIKey.baseURL.rawValue
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .join, .uploadPostImage, .upload, .likeStatus, .uploadComment:
            return .post
        case .tokenRefresh, .checkPosts, .checkSpecificPost, .checkUserPosts, .myProfile, .otherProfile,  .myLikedPosts, .hashtag:
            return .get
        case .deleteComment, .deletePost:
            return .delete
        }
    }
    
    var headers: HTTPHeaders {
        print("----network---", self.path, ", \n headersAccessToken", UserManager.shared.getAccessToken())
        switch self {
        case .tokenRefresh:
            return [HTTPHeader.authorization.rawValue: UserManager.shared.getAccessToken() ?? "",
                    HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                    HTTPHeader.refreshToken.rawValue: UserManager.shared.getRefreshToken() ?? ""] // refreshToken도 들어가야함
        case .login, .join:
            return [HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        case  .upload, .likeStatus, .uploadComment, .hashtag:
            return [HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                    HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                    HTTPHeader.authorization.rawValue: UserManager.shared.getAccessToken() ?? ""]
        case .uploadPostImage:
            return [HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
                    HTTPHeader.contentType.rawValue: HTTPHeader.multipartData.rawValue,
                    HTTPHeader.authorization.rawValue: UserManager.shared.getAccessToken() ?? ""]
        case .checkPosts, .checkSpecificPost, .checkUserPosts, .deletePost, .myProfile, .otherProfile, .myLikedPosts, .deleteComment:
            return [ HTTPHeader.authorization.rawValue: UserManager.shared.getAccessToken() ?? "",
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
        case .myProfile:
            return "v1/users/me/profile"
        case .otherProfile(let userId):
            print("otherProfile network =---------userid : \(userId)")
            return "v1/users/\(userId)/profile"
        case .uploadPostImage:
            return "v1/posts/files"
        case .upload, .checkPosts:
            return "v1/posts"
            
        case .checkSpecificPost(let postId):
            return "v1/posts/\(postId)"
        case .checkUserPosts(let userId):
            return "v1/posts/users/\(userId)/"
        case .deletePost(let postId):
            return "v1/posts/\(postId)"
        case .likeStatus(_, let postId):
            return "v1/posts/\(postId)/like"
        case .myLikedPosts:
            return "v1/posts/likes/me"
        case .uploadComment(_, let postId):
            return "v1/posts/\(postId)/comments"
        case .deleteComment(let postId, let commentId):
            return "v1/posts/\(postId)/comments/\(commentId)"
            
        case .hashtag:
            return "v1/posts/hashtags"
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
        case .uploadComment(let query, _):
            return [ParameterKey.content.rawValue: query.content]
        case .join, .myProfile, .otherProfile, .tokenRefresh, .uploadPostImage, .checkPosts, .checkUserPosts, .checkSpecificPost, .deletePost, .myLikedPosts, .deleteComment, .hashtag:
            return nil
        }
    }
    
    var queryItem: [URLQueryItem]? {
        switch self {
        case .checkPosts(let query):
            return [URLQueryItem(name: QueryKey.next.rawValue, value: query.next),
                    URLQueryItem(name: QueryKey.limit.rawValue, value: query.limit),
                    URLQueryItem(name: QueryKey.product_id.rawValue, value: query.product_id)]
        case .hashtag(let query):
            return [URLQueryItem(name: QueryKey.next.rawValue, value: query.next),
                    URLQueryItem(name: QueryKey.limit.rawValue, value: query.limit),
                    URLQueryItem(name: QueryKey.product_id.rawValue, value: query.product_id),
                    URLQueryItem(name: QueryKey.hashTag.rawValue, value: query.hashTag)]
            
        case .login, .join, .myProfile, .otherProfile, .upload, .tokenRefresh, .uploadPostImage, .checkSpecificPost, .checkUserPosts, .deletePost, .likeStatus, .myLikedPosts, .uploadComment, .deleteComment:
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
        case .uploadComment(let query, _):
            return jsonEncoding(query)
        case .myProfile, .otherProfile, .uploadPostImage, .checkPosts, .checkSpecificPost, .checkUserPosts, .myLikedPosts, .deletePost, .deleteComment, .hashtag:
            return nil
        }
    }
    
    var multipartBody: [Data]? {
        switch self {
        case .tokenRefresh, .login, .join, .myProfile, .otherProfile, .upload, .checkPosts, .checkSpecificPost, .checkUserPosts, .deletePost, .likeStatus, .uploadComment, .deleteComment, .myLikedPosts, .hashtag:
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

