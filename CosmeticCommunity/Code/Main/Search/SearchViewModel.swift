//
//  SearchViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/28.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: InputOutput {
    var outputLoginView: RxRelay.PublishRelay<Void> = PublishRelay<Void>()
    var disposeBag = DisposeBag()
    
    let category = BehaviorSubject(value: PersonalColor.allCases)
    struct Input {
        let inputSearchText: ControlProperty<String?>
        let inputCategorySelected: BehaviorSubject<PersonalColor>
    }
    
    struct Output {
        let outputPostItems: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let outputPostItems = PublishRelay<[PostModel]?>()
        
        let observableSearch = Observable.zip(input.inputSearchText.orEmpty, input.inputCategorySelected)
        
//        observableSearch
//            .flatMap { searchText, category in
//                return
//            }
        return Output(outputPostItems: outputPostItems.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView)
    }
}
