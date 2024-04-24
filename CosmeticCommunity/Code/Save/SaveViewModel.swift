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
    let likeManager = LikeManager()
    
    var outputLoginView = PublishRelay<Void>()
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
                print("imagePath : \(imagePath)")
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
                outputFetchLikedPosts.accept(value.data)
            }
            .disposed(by: disposeBag)
        
        return Output(outputProfileImageTrigger: outputProfileImageTrigger.asDriver(onErrorJustReturn: ""), outputFetchLikedPosts: outputFetchLikedPosts.asDriver(onErrorJustReturn: nil), outputRecentPosts: outputRecentPosts.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView)
    
    }
}