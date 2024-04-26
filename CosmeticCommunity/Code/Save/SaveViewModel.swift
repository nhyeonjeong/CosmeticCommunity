//
//  SaveViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SaveViewModel: InputOutput{
    let userManager = UserManager.shared
    let postManager = PostManager()
    let likeManager = LikeManager()
    
    var outputLoginView = PublishRelay<Void>()
    
    let recentPosts: [PostModel] = []
    var disposeBag = DisposeBag()
    struct Input {
        let inputProfileImageTrigger: PublishSubject<Void>
        let inputFetchLikedPosts: PublishSubject<Void>
        let inputRecentPosts: PublishSubject<Void>
        
    }
    struct Output {
        let outputProfileImageTrigger: Driver<String>
        let outputFetchLikedPosts: Driver<[PostModel]?>
        let outputRecentPosts: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let outputProfileImageTrigger = PublishRelay<String>()
        let outputFetchLikedPosts = PublishRelay<[PostModel]?>()
        let outputRecentPosts = PublishRelay<[PostModel]?>()
        
        input.inputProfileImageTrigger
            .subscribe(with: self) { owner, _ in
                let imagePath = owner.userManager.getProfileImagePath()
//                print("imagePath : \(imagePath)")
                outputProfileImageTrigger.accept(imagePath)
            }
            .disposed(by: disposeBag)
        input.inputFetchLikedPosts
            .flatMap {
                return self.likeManager.getMyLikedPosts()
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputFetchLikedPosts.accept(nil)
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputFetchLikedPosts.onNext(())
                            } failureHandler: {
                                //
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        outputFetchLikedPosts.accept(nil)
                        return Observable<CheckPostModel>.never()
                    }
            }
            .bind(with: self) { owner, value in
                print("😇 \(value)")
                outputFetchLikedPosts.accept(value.data)
            }
            .disposed(by: disposeBag)
        
        input.inputRecentPosts
            .flatMap {
                guard let postIds = self.postManager.getRecentPostsUserDefaults() else {
                    return Observable<[String]>.never()
                }
                print("input.iputRecentPosts: \(postIds)")
                return BehaviorSubject(value: postIds).asObservable()
            }
            .flatMap { postIds in
                var postModelArray: [Observable<PostModel>] = []
                for id in postIds {
//                    let dispatchGroup = DispatchGroup()
//                    dispatchGroup.enter()
//                    print("🥳start")
                    let postObservable = self.postManager.checkSpecificPost(postId: id).catch { error in
                        guard let error = error as? APIError else {
                            outputRecentPosts.accept(nil)
                            return Observable<PostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputRecentPosts.onNext(())
                            } failureHandler: {
//                                outputUploadTrigger.onNext(nil)
                            } loginAgainHandler: {
                                self.outputLoginView.accept(())
                            }
                        }
//                        print("🥳end")
                        outputRecentPosts.accept(nil)
                        return Observable<PostModel>.never()
                    }
//                    dispatchGroup.leave()
//                    dispatchGroup.notify(queue: .main) {
//                        postModelArray.append(postObservable) // Observable<PostModel> 배열 추가
//                    }
                    print("🥳end")
                    postModelArray.append(postObservable) // Observable<PostModel> 배열 추가
                }
                let singleObservable: Observable<PostModel> = Observable.from(postModelArray).merge()
                let wholeSequence: Single <[PostModel]> = singleObservable.toArray()
                return wholeSequence
            }
            .subscribe(with: self) { owner, data in
//                print("input.iputRecentPosts: ------------\(data)")
                outputRecentPosts.accept(data)
            }
            .disposed(by: disposeBag)
        
        return Output(outputProfileImageTrigger: outputProfileImageTrigger.asDriver(onErrorJustReturn: ""), outputFetchLikedPosts: outputFetchLikedPosts.asDriver(onErrorJustReturn: nil), outputRecentPosts: outputRecentPosts.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView)
    
    }
}
