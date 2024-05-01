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
    let userManager = UserManager.shared
    let postManager = PostManager()
    let outputLoginView = PublishRelay<Void>()
    
    var nextCursor = "0" // 결과로 가져온 다음 커서
    var checkPostQuery : BehaviorSubject<CheckPostQuery> {
        BehaviorSubject<CheckPostQuery>(value: CheckPostQuery(next: nextCursor, product_id: "nhj_test"))
    }
    struct Input {
        let inputProfileImageTrigger: PublishSubject<Void>
    }
    
    struct Output {
        let outputProfileImageTrigger: Driver<String>
        let outputLoginView: PublishRelay<Void>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let outputProfileImageTrigger = PublishRelay<String>()
        input.inputProfileImageTrigger
            .subscribe(with: self) { owner, _ in
                
                let imagePath = owner.userManager.getProfileImagePath()
                outputProfileImageTrigger.accept(imagePath)
            }
            .disposed(by: disposeBag)
        
       
        
        return Output(outputProfileImageTrigger: outputProfileImageTrigger.asDriver(onErrorJustReturn: ""), outputLoginView: outputLoginView)
    }
}
