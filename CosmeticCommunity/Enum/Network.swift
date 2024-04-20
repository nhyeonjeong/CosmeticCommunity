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

enum ParameterKey: String {
    case email
    case password
    case product_id
    case title
    case content
    case content1 // 퍼스널 컬러
    case files
}
enum QueryKey: String {
    case next
    case limit
    case product_id
}
enum APIError: Error {
    case sesacKeyError_420
    case overCallError_429
    case invalidURLError_444
    case serverError_500
    
    case requestError_400 // body필수값 누락 또는 파일의 제한 사항과 맞지 않음 / 잘못된 요청
    case invalidUserError_401 // 미가입이거나 비밀번호 불일치 또는 유효하지 않는 엑세스 토큰 요청
    
    case forbiddenError_403 // 접근 권한이 없는 경우
    case alreadyFollow_409 // 이미 팔로윙 된 계정
    case dbError_410 // DB서버 장애로 게시글이 저장되지 않았을 때, 게시글을 못 찾겠을 때, 댓글 없을 때, 알 수 없는 계정
    case refreshTokenExpired_418 // 리프레시 토큰이 만료, 다시 로그인
    case accessTokenExpired_419 // 엑세스 토큰 만료 갱신필요
    case noPostAuthority_445 // 게시글 수정, 삭제 권한 없음
    
    var errorMessage: String {
        switch self {
        case .sesacKeyError_420:
            return "420"
        case .overCallError_429:
            return "429"
        case .invalidURLError_444:
            return "444"
        case .serverError_500:
            return "500"
        case .requestError_400:
            return "400"
        case .invalidUserError_401:
            return "401오ㅖ~"
        case .forbiddenError_403:
            return "403"
        case .alreadyFollow_409:
            return "409"
        case .dbError_410:
            return "410"
        case .refreshTokenExpired_418:
            return "418"
        case .accessTokenExpired_419:
            return "419"
        case .noPostAuthority_445:
            return "445"
        }
    }
}

