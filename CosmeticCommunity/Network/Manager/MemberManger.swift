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
        UserDefaults.standard.setValue(token, forKey: UserDefaultKey.Member.refreshToken.rawValue)
    }
    
    // 유저아이디 가져오기
    func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.Member.userId.rawValue)
    }
    // 유저아이디 저장
    func saveUserId(_ id: String) {
        UserDefaults.standard.setValue(id, forKey: UserDefaultKey.Member.userId.rawValue)
    }
    
    func login(_ data: LoginQuery) -> Observable<LoginModel> {
//        print(data)
        return NetworkManager.shared.fetchAPI(type: LoginModel.self, router: Router.login(query: data), completionHandler: { response in
            print("accessToken refresh result: ", response.accessToken)
            self.saveUserId(response.user_id)
            self.saveAccessToken(response.accessToken)
            print("save UserDefaults: \(self.getAccessToken() ?? "")")
            self.saveRefreshToken(response.refreshToken)
        })
    }
    
    func join() {
        
    }
    
    func withdraw() {
        
    }
    
    func checkInvalidEmail() {
        
    }
    // 내 프로필 확인
    func checkMyProfile() -> Observable<UserModel> {
        return NetworkManager.shared.fetchAPI(type: UserModel.self, router: Router.myProfile)
    }
    
}
