//
//  SearchViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import Foundation
import RxSwift
import RxCocoa

final class HomeViewModel: InputOutput {
    let postManager = PostManager()
    var disposedBag = DisposeBag()
    
    var nextCursor = "0" // 결과로 가져온 다음 커서
    var checkPostQuery : BehaviorSubject<CheckPostQuery> {
        BehaviorSubject<CheckPostQuery>(value: CheckPostQuery(next: nextCursor, product_id: "nhj_test"))
    }
    struct Input {
        let inputFetchPostsTrigger: PublishSubject<Void>
    }
    
    struct Output {
        let outputPostItems: Driver<[PostModel]?>
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
                        /*
                        guard let error = error as? APIError else {
                            outputPostsItems.accept(nil)
                        }
                        */
                        outputPostItems.accept(nil)
                        return Observable<CheckPostModel>.never()
                    }
            }
            .bind(with: self) { owner, posts in
                
                outputPostItems.accept(posts.data)
                owner.nextCursor = posts.next_cursor
            }
            .disposed(by: disposedBag)
        
        return Output(outputPostItems: outputPostItems.asDriver(onErrorJustReturn: []))
    }
}
