//
//  RouterType.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import Foundation
import Alamofire

protocol RouterType: URLRequestConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var header: [String: String] { get }
    var path: String { get }
    // 아래는 없을 수도 있어서 옵셔널
    var parameters: String? { get }
    var queryItem: [URLQueryItem]? { get }
    var body: Data? { get } // 사진이나 영상, 음악을 올린다고 할 때 데이터 형식이다.
}

extension RouterType {
    func asURLRequest() throws -> URLRequest {
        // asURL : 이 메서드를 사용해서 URLConvertable에 구현되어 있음
        let url = try baseURL.asURL()
        var urlRequest = try URLRequest(url: url.appendingPathComponent(path), method: method)
        urlRequest.allHTTPHeaderFields = header
        urlRequest.httpBody = parameters?.data(using: .utf8)
        urlRequest.httpBody = body
        return urlRequest
    }
}
