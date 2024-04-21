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
    //
    func accessTokenAPI(completionHandler: @escaping(() -> Void), failureHandler: @escaping (() -> Void), loginAgainHandler: @escaping (() -> Void)) {
        print("엑세스토큰 재발행")
        MemberManger.shared.tokenRefresh()
            .catch { error in
                guard let error = error as? APIError else {
                    failureHandler()
                    return Observable<RefreshAccessModel>.never()
                }
                if error == .refreshTokenExpired_418 || error == .invalidUserError_401 {
                    print("리프레시토큰 만료")
                    loginAgainHandler()
                }
                return Observable<RefreshAccessModel>.never()
            }
            .subscribe(with: self) { owner, _ in
                completionHandler()
            }
            .disposed(by: disposeBag)
    }
        
}
