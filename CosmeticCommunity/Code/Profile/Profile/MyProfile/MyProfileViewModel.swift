//
//  ProfileViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import Foundation
import RxSwift
import RxCocoa

final class MyProfileViewModel: InputOutput {
    
    struct FollowCounts {
        let countLabel: Int
        let countTitle: String
    }
    let userManager = UserManager.shared
    let outputLoginView = PublishRelay<Void>()
    struct Input {
        let inputFetchProfile: PublishSubject<Void>
    }
    
    struct Output {
        let outputProfileResult: Driver<UserModel?>
//        let outputFollowResult: Driver<UserModel?>
        let outputPostsResult: Driver<[PostModel]?>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let outputProfileResult = PublishSubject<UserModel?>()
        let fetchMyPostsSubject = PublishSubject<[String]?>()
//        let outputFollowResult = PublishSubject<UserModel?>()
        let outputPostsResult = PublishSubject<[PostModel]?>()

        input.inputFetchProfile
            .flatMap {
                return self.userManager.checkMyProfile()
                    .catch { error in
                        print("에러발생")
                        guard let error = error as? APIError else {
                            outputProfileResult.onNext(nil)
//                            outputFollowResult.onNext(nil)
                            fetchMyPostsSubject.onNext(nil)
                            return Observable<UserModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputFetchProfile.onNext(())
                            } failureHandler: {
                                outputProfileResult.onNext(nil)
//                                outputFollowResult.onNext(nil)
                                fetchMyPostsSubject.onNext(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        outputProfileResult.onNext(nil)
                        fetchMyPostsSubject.onNext(nil)
                        return Observable<UserModel>.never()
                    }
            }
            .subscribe(with: self) { owner, data in
                outputProfileResult.onNext(data)
//                outputFollowResult.onNext(data)
                fetchMyPostsSubject.onNext(data.posts)
            }
            .disposed(by: disposeBag)
        
//        fetchMyPostsSubject
//            .flatMap {
//                return
//            }
//            .bind(with: self) { owner, value in
//                <#code#>
//            }
        return Output(outputProfileResult: outputProfileResult.asDriver(onErrorJustReturn: nil), outputPostsResult: outputPostsResult.asDriver(onErrorJustReturn: nil))
    }
}
