//
//  TokenManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import Foundation
import RxSwift
import RxCocoa

final class TokenManager {
    static let shared = TokenManager()
    let disposeBag = DisposeBag()
    private init() { }
    
    func accessTokenAPI(completionHandler: @escaping(() -> Void), failureHandler: @escaping (() -> Void), loginAgainHandler: @escaping (() -> Void)) {
        print("엑세스토큰 재발행")
        tokenRefresh()
            .catch { error in
                guard let error = error as? APIError else {
                    failureHandler()
                    return Observable<RefreshAccessModel>.never()
                }
                if error == .refreshTokenExpired_418 || error == .invalidUserError_401 {
                    print("리프레시토큰 만료")
                    loginAgainHandler()
                    // 다시 로그인 하면서 유저디폴트에 관련 내용도 삭제
                    UserManager.shared.deleteAccessToken()
                    UserManager.shared.deleteRefreshToken()
                    UserManager.shared.deleteUserId()
                }
                return Observable<RefreshAccessModel>.never()
            }
            .subscribe(with: self) { owner, _ in
                completionHandler()
            }
            .disposed(by: disposeBag)
    }
    // 엑세스토큰이 만료됐을 때
    func tokenRefresh() -> Observable<RefreshAccessModel> {

        return NetworkManager.shared.fetchAPI(type: RefreshAccessModel.self, router: Router.tokenRefresh) { response in
            UserManager.shared.saveAccessToken(response.accessToken)
        }
    }
        
}
