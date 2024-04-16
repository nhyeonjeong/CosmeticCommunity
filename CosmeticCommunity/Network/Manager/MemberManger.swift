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

final class MemberManger {
    static let shared = MemberManger()
    
    private init() { }
    // accessToken가져오기
    func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.Member.accessToken.rawValue)
    }
    // accessToken저장
    func saveAccessToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: UserDefaultKey.Member.accessToken.rawValue)
    }
    
    // refreshToken가져오기
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.Member.refreshToken.rawValue)
    }
    // RefreshToken저장
    func saveRefreshToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: UserDefaultKey.Member.accessToken.rawValue)
    }
    
    // 유저아이디 가져오기
    func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.Member.userId.rawValue)
    }
    // 유저아이디 저장
    func saveUserId(_ id: String) {
        UserDefaults.standard.setValue(id, forKey: UserDefaultKey.Member.userId.rawValue)
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
//
//        AF.request(url, method: .get, headers: headers)
//            .responseDecodable(of: RefreshTokenModel.self) { response in
//                switch response.result {
//                case .success(let value):
//                    self.label.text = "토큰 갱신 성공 \n\(value)"
//                    // 다시 유저디폴트에 저장
//                    UserDefaults.standard.set(value.accessToken, forKey: "accessToken")
//                    completionHandler()
//                case .failure(_):
//                    // 실패했ㅇ르 떄는 상태코드 체크하고 로직에 맞게 대응
//                    if let code = response.response?.statusCode {
//                        self.label.text = "토큰 갱신 실패: \(code)"
//                    } else {
//                        self.label.text = "토큰 갱신 실패"
//                    }
//                }
//            }

    }
    
    func login(_ data: LoginQuery) -> Observable<LoginModel>{
        print(data)
        return NetworkManager.shared.fetchAPI(type: LoginModel.self, router: Router.login(query: data))
    }
    
    func join() {
        
    }
    
    func withdraw() {
        
    }
    
    func checkInvalidEmail() {
        
    }
    
}
