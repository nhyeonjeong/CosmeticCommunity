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
    var data: [PostModel] = []
    var disposedBag = DisposeBag()
    struct Input {
        let inputFetchPostsTrigger: PublishSubject<Void>
    }
    
    struct Output {
        let outputPostsItems: Driver<[PostModel]>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let outputPostsItems = PublishRelay<[PostModel]>()
        input.inputFetchPostsTrigger
//            .flatMap {
//                return
//            }
            .bind(with: self) { owner, posts in
                outputPostsItems.accept(owner.data)
            }
            .disposed(by: disposedBag)
        
        return Output(outputPostsItems: outputPostsItems.asDriver(onErrorJustReturn: []))
    }
}
