//
//  OtherProfileViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import Foundation
import RxSwift
import RxCocoa

final class OtherProfileViewModel: InputOutput {
    let userManager = UserManager.shared
    let postManager = PostManager()
    var disposeBag = DisposeBag()
    
    var outputLoginView = PublishRelay<Void>()
    var userId = ""
    struct Input {
        let inputFetchProfile: BehaviorSubject<String?>
    }
    
    struct Output {
        let outputProfileResult: Driver<UserModel?>
        let outputPostItems: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let outputProfileResult = PublishSubject<UserModel?>()
        let fetchPostsSubject = PublishSubject<[String]?>()
        let outputPostItems = PublishSubject<[PostModel]?>()
        
        // 만약 탈퇴한 회원이라면??
        input.inputFetchProfile
            .flatMap { id in
                guard let id else {
                    outputProfileResult.onNext(nil)
                    fetchPostsSubject.onNext(nil)
                    return Observable<UserModel>.never()
                }
                self.userId = id
                return self.userManager.checkOtherProfile(userId: id)
                    .catch { error in
                        print("에러발생")
                        guard let error = error as? APIError else {
                            outputProfileResult.onNext(nil)
                            fetchPostsSubject.onNext(nil)
                            return Observable<UserModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputFetchProfile.onNext(id)
                            } failureHandler: {
//                                outputProfileResult.onNext(nil)
//                                fetchMyPostsSubject.onNext(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        outputProfileResult.onNext(nil)
                        fetchPostsSubject.onNext(nil)
                        return Observable<UserModel>.never()
                    }
            }
            .subscribe(with: self) { owner, data in
//                print("상대방 프로필 패치 후 \(data.user_id)")
                outputProfileResult.onNext(data)
                fetchPostsSubject.onNext(data.posts)
            }
            .disposed(by: disposeBag)
        
        fetchPostsSubject
            .flatMap { posts in
                return self.postManager.checkUserPosts(userId: self.userId)
                    .catch { error in
                        print("에러발생")
                        guard let error = error as? APIError else {
                            outputPostItems.onNext(nil)
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                fetchPostsSubject.onNext(posts)
                            } failureHandler: {
                                //
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        outputPostItems.onNext(nil)
                        return Observable<CheckPostModel>.never()
                    }
            }
            .bind(with: self) { owner, value in
                outputPostItems.onNext(value.data)
            }
            .disposed(by: disposeBag)
        return Output(outputProfileResult: outputProfileResult.asDriver(onErrorJustReturn: nil), outputPostItems: outputPostItems.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView)
    }
}
