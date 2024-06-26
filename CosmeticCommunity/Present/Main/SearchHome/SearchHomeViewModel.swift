//
//  SearchViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/28.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchHomeViewModel: InputOutput {
    let userManager = UserManager.shared
    let postManager = PostManager()
    let outputLoginView = PublishRelay<Void>()
    
    var nextCursor = "0" // 결과로 가져온 다음 커서
    var checkPostQuery : BehaviorSubject<CheckPostQuery> {
        BehaviorSubject<CheckPostQuery>(value: CheckPostQuery(next: nextCursor, product_id: "nhj_test"))
    }
    struct Input {
        let inputFetchPostsTrigger: PublishSubject<Void>
        let inputPrefetchTrigger: PublishSubject<[IndexPath]>
    }
    
    struct Output {
        let outputPostItems: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let outputPostItems = PublishRelay<[PostModel]?>()
        
        input.inputFetchPostsTrigger
            .withLatestFrom(checkPostQuery.asObserver())
            .flatMap { data in
                // 포스트 불러오기
                return self.postManager.checkPosts(data)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputPostItems.accept(nil)
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputFetchPostsTrigger.onNext(())
                            } failureHandler: {
                                outputPostItems.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        outputPostItems.accept(nil)
                        return Observable<CheckPostModel>.never()
                    }
            }
            .bind(with: self) { owner, posts in
                
                outputPostItems.accept(posts.data)
                owner.nextCursor = posts.next_cursor
            }
            .disposed(by: disposeBag)
        
        return Output(outputPostItems: outputPostItems.asDriver(onErrorJustReturn: []), outputLoginView: outputLoginView)
    }
}
