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
    let userManager = UserManager.shared
    let postManager = PostManager()
    let outputLoginView = PublishRelay<Void>()
    
    var nextCursor: String = ""
    var postData: [PostModel] = []
    struct Input {
        let inputFetchProfile: PublishSubject<Void>
    }
    
    struct Output {
        let outputProfileResult: Driver<UserModel?>
        let outputPostItems: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
        let outputNoResult: Driver<Bool>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let outputProfileResult = PublishSubject<UserModel?>()
        let fetchMyPostsSubject = PublishSubject<[String]?>()
        let outputPostItems = PublishSubject<[PostModel]?>()
        let outputNoResult = PublishRelay<Bool>()
        
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
//                                outputProfileResult.onNext(nil)
//                                fetchMyPostsSubject.onNext(nil)
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
//                print("내 프로필 패치 후 \(data.user_id)")
                outputProfileResult.onNext(data)
                fetchMyPostsSubject.onNext(data.posts)
            }
            .disposed(by: disposeBag)
        
        fetchMyPostsSubject
            .flatMap { posts in
                let query = CheckPostQuery(next: self.nextCursor, limit: "20", product_id: nil)
                return self.postManager.checkUserPosts(userId: self.userManager.getUserId() ?? "", query: query)
                    .catch { error in
                        print("에러발생")
                        guard let error = error as? APIError else {
                            outputPostItems.onNext(nil)
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                fetchMyPostsSubject.onNext(posts)
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
                owner.postData.append(contentsOf: value.data)
                outputPostItems.onNext(value.data)
                
                if value.data.count == 0 {
                    outputNoResult.accept(false)
                } else {
                    outputNoResult.accept(true)
                }
                owner.nextCursor = value.next_cursor
//                owner.limit = "20" // limit 다시 돌리기
            }
            .disposed(by: disposeBag)
        return Output(outputProfileResult: outputProfileResult.asDriver(onErrorJustReturn: nil), outputPostItems: outputPostItems.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView, outputNoResult: outputNoResult.asDriver(onErrorJustReturn: false))
    }
}
