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
    var limit = "20" // 디폴트
    struct Input {
        let inputFetchProfile: PublishSubject<Void>
        let inputPrepatchTrigger: PublishSubject<[IndexPath]>
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
        let fetchMyPostsSubject = PublishSubject<Void?>()
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
                outputProfileResult.onNext(data)
                fetchMyPostsSubject.onNext(())
            }
            .disposed(by: disposeBag)
        
        fetchMyPostsSubject
            .flatMap { posts in
                if self.nextCursor == "0" {
                    return Observable<CheckPostModel>.empty()
                }
                print("네트워크통신!!!!!😎")
                let query = CheckPostQuery(next: self.nextCursor, limit: self.limit, product_id: nil)
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
                outputPostItems.onNext(owner.postData)
                print("😎postData.append 후에 : \(owner.postData.count)")
                
                if value.data.count == 0 {
                    outputNoResult.accept(false)
                } else {
                    outputNoResult.accept(true)
                }
                print("😎nextCursor : \(value.next_cursor)")
                owner.nextCursor = value.next_cursor
                owner.limit = "20" // limit 다시 돌리기
            }
            .disposed(by: disposeBag)
        
        // prefetch
        input.inputPrepatchTrigger
            .flatMap { indexPaths in
                let row = indexPaths.first?.row
                // 한 줄에 세 개니까 조건문 3개
                if row == self.postData.count - 4 || row == self.postData.count - 5 || row == self.postData.count - 6 {
                    print("😎\(row)")
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(with: self) { owner, _ in
                print("😎prefetch하자!~!~!~~!")
                fetchMyPostsSubject.onNext(())
            }
            .disposed(by: disposeBag)
        
        
        return Output(outputProfileResult: outputProfileResult.asDriver(onErrorJustReturn: nil), outputPostItems: outputPostItems.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView, outputNoResult: outputNoResult.asDriver(onErrorJustReturn: false))
    }
}
