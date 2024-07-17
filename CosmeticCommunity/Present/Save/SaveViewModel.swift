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
    let outputNotInNetworkTrigger = PublishRelay<(() -> Void)?>()
    
    let recentPosts: [PostModel] = []
    var disposeBag = DisposeBag()
    struct Input {
        let inputProfileImageTrigger: PublishSubject<Void>
        let inputFetchLikedPosts: PublishSubject<Void>
        let inputRecentPosts: PublishSubject<Void>
        
    }
    struct Output {
        let outputProfileImageTrigger: Driver<String?>
        let outputFetchLikedPosts: Driver<[PostModel]?>
        let outputRecentPosts: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
        let outputNotInNetworkTrigger: PublishRelay<(() -> Void)?>
    }
    
    func transform(input: Input) -> Output {
        let outputProfileImageTrigger = PublishRelay<String?>()
        let outputFetchLikedPosts = PublishRelay<[PostModel]?>()
        let outputRecentPosts = PublishRelay<[PostModel]?>()
        
        input.inputProfileImageTrigger
            .subscribe(with: self) { owner, _ in
                let imagePath = owner.userManager.getProfileImagePath()
                outputProfileImageTrigger.accept(imagePath)
            }
            .disposed(by: disposeBag)
        input.inputFetchLikedPosts
            .flatMap {
                return self.likeManager.getMyLikedPosts()
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputFetchLikedPosts.accept(nil)
                            return Observable<CheckPostModel>.empty()
                        }
                        if error == APIError.notInNetwork {
                            self.outputNotInNetworkTrigger.accept {
                                input.inputFetchLikedPosts.onNext(())
                            }
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
                owner.outputNotInNetworkTrigger.accept(nil)
                outputFetchLikedPosts.accept(value.data)
            }
            .disposed(by: disposeBag)
        // 최근 본 포스트
        input.inputRecentPosts
            .flatMap {
                guard let postIds = self.postManager.getRecentPostsUserDefaults() else {
                    return Observable<[String]>.never()
                }
                return BehaviorSubject(value: postIds).asObservable()
            }
            .flatMap { postIds in
                var postModelArray: [Observable<PostModel>] = []
                for id in postIds {

                    let postObservable = self.postManager.checkSpecificPost(postId: id).catch { error in
                        guard let error = error as? APIError else {
                            outputRecentPosts.accept(nil)
                            return Observable<PostModel>.empty()
                        }
                        if error == APIError.notInNetwork {
                            self.outputNotInNetworkTrigger.accept {
                                input.inputRecentPosts.onNext(())
                            }
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
                        outputRecentPosts.accept(nil)
                        return Observable<PostModel>.empty()
                    }
                    postModelArray.append(postObservable) // Observable<PostModel> 배열 추가
                }
                // <PostModel>을 <[PostModel]>로 바꿔줌
                let singleObservable: Observable<PostModel> = Observable.from(postModelArray).merge()
                let wholeSequence: Single <[PostModel]> = singleObservable.toArray()
                return wholeSequence
            }
            .subscribe(with: self) { owner, data in
                print("🍕", data)
                owner.outputNotInNetworkTrigger.accept(nil)
                // 정렬은 userdefault배열대로 다시 정렬
                var getData: [PostModel] = []
                getData = data
                outputRecentPosts.accept(owner.sortRecentPosts(data: getData))
            }
            .disposed(by: disposeBag)
        
        return Output(outputProfileImageTrigger: outputProfileImageTrigger.asDriver(onErrorJustReturn: ""), outputFetchLikedPosts: outputFetchLikedPosts.asDriver(onErrorJustReturn: nil), outputRecentPosts: outputRecentPosts.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView, outputNotInNetworkTrigger: outputNotInNetworkTrigger)
    
    }
    func sortRecentPosts(data: [PostModel]) -> [PostModel] {
        guard let postIds = postManager.getRecentPostsUserDefaults() else {
            return []
        }
        var numberToIndexMap: [String: Int] = [:]
        for (index, element) in postIds.enumerated() {
            numberToIndexMap[element] = index
        }

        // numberToIndexMap을 사용하여 PostModel 배열을 정렬
        let sortedPostModels = data.sorted(by: {
            guard let index1 = numberToIndexMap[$0.post_id], let index2 = numberToIndexMap[$1.post_id] else {
                return false // numberToIndexMap에 해당하는 number가 없을 경우 false 반환
            }
            return index1 < index2
        })
        
        return sortedPostModels
    }
}


