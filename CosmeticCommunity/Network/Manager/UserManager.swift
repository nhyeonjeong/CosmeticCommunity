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
    // accessToken저장
    func saveAccessToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: UserDefaultKey.User.accessToken.rawValue)
    }
    func deleteAccessToken() {
        UserDefaults.standard.set(nil, forKey: UserDefaultKey.User.accessToken.rawValue)
        UserDefaults.standard.synchronize() // 변경사항 즉시 동기화
    }
    
    // refreshToken가져오기
    func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.User.refreshToken.rawValue)
    }
    // RefreshToken저장
    func saveRefreshToken(_ token: String) {
        UserDefaults.standard.setValue(token, forKey: UserDefaultKey.User.refreshToken.rawValue)
    }
    func deleteRefreshToken() {
        UserDefaults.standard.set(nil, forKey: UserDefaultKey.User.refreshToken.rawValue)
        UserDefaults.standard.synchronize() // 변경사항 즉시 동기화
    }
    
    // 유저아이디 가져오기
    func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultKey.User.userId.rawValue)
    }
    // 유저아이디 저장
    func saveUserId(_ id: String) {
        UserDefaults.standard.setValue(id, forKey: UserDefaultKey.User.userId.rawValue)
    }
    func deleteUserId() {
        UserDefaults.standard.set(nil, forKey: UserDefaultKey.User.userId.rawValue)
        UserDefaults.standard.synchronize() // 변경사항 즉시 동기화
    }
    
    // 프로필이미지 경로 가져오기
    func getProfileImagePath() -> String {
        if let path = UserDefaults.standard.string(forKey: UserDefaultKey.User.profileImagePath.rawValue) {
            return path
        } else {
            return Constants.Image.defualtProfilePath
        }
    }
    // 프로필이미지 경로 저장
    func saveProfileImagePath(_ path: String) {
        UserDefaults.standard.setValue(path, forKey: UserDefaultKey.User.profileImagePath.rawValue)
    }

    func login(_ data: LoginQuery) -> Observable<LoginModel> {
//        print(data)
        return NetworkManager.shared.fetchAPI(type: LoginModel.self, router: Router.login(query: data), completionHandler: { response in
            print("accessToken refresh result: ", response.accessToken)
            self.saveUserId(response.user_id)
            self.saveAccessToken(response.accessToken)
            self.saveRefreshToken(response.refreshToken)
            
            self.saveProfileImagePath(response.profileImage) // 유저의 프로필이미지 경로도 유저디폴트에 저장!
        })
    }
    
    func join() {
        
    }
    
    func withdraw() {
        
    }
    
    func checkInvalidEmail(_ data: ValidEmailQuery) -> Observable<ValidMessageModel> {
        return NetworkManager.shared.fetchAPI(type: ValidMessageModel.self, router: Router.validEmail(query: data))
    }
    // 내 프로필 확인
    func checkMyProfile() -> Observable<UserModel> {
        return NetworkManager.shared.fetchAPI(type: UserModel.self, router: Router.myProfile)
    }
    
    // 상대 프로필 확인
    func checkOtherProfile(userId: String) -> Observable<UserModel> {
        return NetworkManager.shared.fetchAPI(type: UserModel.self, router: Router.otherProfile(userId: userId))
    }
    
}
