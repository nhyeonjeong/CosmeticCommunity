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
    var nextCursor: String = ""
    var postData: [PostModel] = []
    var limit = "20" // 디폴트
    struct Input {
        let inputFetchProfile: BehaviorSubject<String?>
        let inputPrepatchTrigger: PublishSubject<[IndexPath]>
    }
    
    struct Output {
        let outputProfileResult: Driver<UserModel?>
        let outputPostItems: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
        let outputNoResult: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let outputProfileResult = PublishSubject<UserModel?>()
        let fetchPostsSubject = PublishSubject<Void?>()
        let outputPostItems = PublishSubject<[PostModel]?>()
        let outputNoResult = PublishRelay<Bool>()
        
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
                                //
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
            .debug()
            .subscribe(with: self) { owner, data in
                print("😆inputFetchProfile")
                outputProfileResult.onNext(data)
                fetchPostsSubject.onNext(())
            }
            .disposed(by: disposeBag)
        
        fetchPostsSubject
            .flatMap { _ in
                if self.nextCursor == "0" {
                    return Observable<CheckPostModel>.empty()
                }
                let query = CheckPostQuery(next: self.nextCursor, limit: self.limit, product_id: nil)
                return self.postManager.checkUserPosts(userId: self.userId, query: query)
                    .catch { error in
                        print("에러발생")
                        guard let error = error as? APIError else {
                            outputPostItems.onNext(nil)
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                fetchPostsSubject.onNext(())
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
                
                if value.data.count == 0 {
                    outputNoResult.accept(false)
                } else {
                    outputNoResult.accept(true)
                }
                owner.nextCursor = value.next_cursor
                owner.limit = "20" // viewWillAppear에서 limit이 바뀌었을 때 limit 다시 돌리기
            }
            .disposed(by: disposeBag)
        
        input.inputPrepatchTrigger
            .flatMap { indexPaths in
                let row = indexPaths.first?.row
                // 한 줄에 세 개니까 조건문 3개
                if row == self.postData.count - 4 || row == self.postData.count - 5 || row == self.postData.count - 6 {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(with: self) { owner, _ in
                fetchPostsSubject.onNext(())
            }
            .disposed(by: disposeBag)
        
        return Output(outputProfileResult: outputProfileResult.asDriver(onErrorJustReturn: nil), outputPostItems: outputPostItems.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView, outputNoResult: outputNoResult.asDriver(onErrorJustReturn: false))
    }
}
