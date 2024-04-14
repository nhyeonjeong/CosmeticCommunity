//
//  UserManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

final class UserManager {
    static let shared = UserManager()
    
    private init() { }
    // accessToken가져오기
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.User.accessToken.rawValue)
    }
    
    // refreshToken가져오기
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.User.refreshToken.rawValue)
    }
    
    // 유저아이디 가져오기
    func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.User.userId.rawValue)
    }
    
    // 엑세스토큰이 만료됐을 때
    func accessTokenRefresh(completionHandler: @escaping (() -> Void)) {
        guard let url = URL(string: APIKey.baseURL.rawValue + "v1/auth/refresh") else {
            print(#function, "unvalid URL")
            return
        }
        guard let accessToken = getAccessToken() else {
            print(#function, "accessToken failure")
            return
        }
        guard let refreshToken = getRefreshToken() else {
            print(#function, "refreshToken failure")
            return
        }
        let headers: HTTPHeaders = [
            HTTPHeader.authorization.rawValue: accessToken,
            HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue,
            HTTPHeader.refreshToken.rawValue: refreshToken // refreshToken도 들어가야함
        ]

        AF.request(url, method: .get, headers: headers)
            .responseDecodable(of: RefreshTokenModel.self) { response in
                switch response.result {
                case .success(let value):
                    self.label.text = "토큰 갱신 성공 \n\(value)"
                    // 다시 유저디폴트에 저장
                    UserDefaults.standard.set(value.accessToken, forKey: "accessToken")
                    completionHandler()
                case .failure(_):
                    // 실패했ㅇ르 떄는 상태코드 체크하고 로직에 맞게 대응
                    if let code = response.response?.statusCode {
                        self.label.text = "토큰 갱신 실패: \(code)"
                    } else {
                        self.label.text = "토큰 갱신 실패"
                    }
                }
            }

    }
    
}
