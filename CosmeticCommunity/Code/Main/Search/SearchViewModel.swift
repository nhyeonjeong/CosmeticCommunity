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
    let categoryCases = BehaviorSubject(value: PersonalColor.personalCases)
    struct Input {
        let inputSearchText: ControlProperty<String?>
        let inputSearchEnterTrigger: ControlEvent<Void>
        let inputCategorySelected: BehaviorSubject<PersonalColor>
    }
    
    struct Output {
        let outputPostItems: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
        let outputNoResult: Driver<Bool>
        
        let outputHideRecentSearch: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let outputPostItems = PublishRelay<[PostModel]?>()
        let searchTrigger = PublishSubject<(String, PersonalColor)>()
        let outputNoResult = PublishRelay<Bool>()
        let outputHideRecentSearch = PublishRelay<Bool>()
        
        Observable.combineLatest(input.inputSearchEnterTrigger, input.inputCategorySelected.asObserver())
            .map{_, category in
                self.category = category
            }
            .debug()
            .withLatestFrom(input.inputSearchText.orEmpty)
            .bind(with: self) { owner, value in
                print("😇")
                searchTrigger.onNext((value, owner.category)) // 하나라도 반응하면 네트워크 통신
                
                // 최근검색어 사라지게
                outputHideRecentSearch.accept(true)
            }
            .disposed(by: disposeBag)
        
        searchTrigger
            .flatMap { hashTag, category in
                let query = HashtagQuery(next: self.nextCursor, product_id: "\(ProductId.baseProductId)\(category.rawValue)", hashTag: hashTag)
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
                if owner.category == .none {
                    outputPostItems.accept(value.data)
                } else {
                    let data = value.data.filter{$0.personalColor == owner.category}
                    outputPostItems.accept(data)
                }
                if value.data.count == 0 {
                    outputNoResult.accept(false)
                } else {
                    outputNoResult.accept(true)
                }
                owner.nextCursor = value.next_cursor
            }
            .disposed(by: disposeBag)
        return Output(outputPostItems: outputPostItems.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView, outputNoResult: outputNoResult.asDriver(onErrorJustReturn: false), outputHideRecentSearch: outputHideRecentSearch.asDriver(onErrorJustReturn: false))
    }
}
