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
    let postManager = PostManager()
    var outputLoginView: RxRelay.PublishRelay<Void> = PublishRelay<Void>()
    var disposeBag = DisposeBag()
    var nextCursor: String = ""
    var category: PersonalColor = .none
    let categoryCases = BehaviorSubject(value: PersonalColor.allCases)
    struct Input {
        let inputSearchText: ControlProperty<String?>
        let inputSearchEnterTrigger: ControlEvent<Void>
        let inputCategorySelected: BehaviorSubject<PersonalColor>
    }
    
    struct Output {
        let outputPostItems: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let outputPostItems = PublishRelay<[PostModel]?>()
        let searchTrigger = PublishSubject<(String, PersonalColor)>()
        
        let observableText = input.inputSearchText.orEmpty.asObservable()
        let observableSearch = Observable.zip(input.inputSearchEnterTrigger, input.inputCategorySelected.asObservable())
            .map{_, category in
                self.category = category
            }
            .debug()
            .withLatestFrom(input.inputSearchText.orEmpty)
            .bind(with: self) { owner, value in
                searchTrigger.onNext((value, owner.category)) // 하나라도 반응하면 네트워크 통신
            }
        
        searchTrigger
            .flatMap { hashTag, category in
                let query = HashtagQuery(next: self.nextCursor, product_id: "nhj_test", hashTag: hashTag)
                return self.postManager.checkWithHashTag(query: query)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputPostItems.accept(nil)
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                searchTrigger.onNext((hashTag, category))
                            } failureHandler: {
//                                outputPostItems.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        outputPostItems.accept(nil)
                        return Observable<CheckPostModel>.never()
                    }
            }
            .subscribe(with: self) { owner, value in
                outputPostItems.accept(value.data)
                owner.nextCursor = value.next_cursor
            }
            .disposed(by: disposeBag)
        return Output(outputPostItems: outputPostItems.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView)
    }
}
