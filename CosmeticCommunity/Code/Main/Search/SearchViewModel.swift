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
    
    var postData: [PostModel] = []
    var nextCursor: String = ""
    var selectedCategory: PersonalColor = .spring
    var limit = "20" // 디폴트
    
    let categoryCases = BehaviorSubject(value: PersonalColor.personalCases)
    
    struct Input {
        let inputSearchText: ControlProperty<String?>
        let inputSearchEnterTrigger: ControlEvent<Void>
        let inputRemoveRecent: ControlEvent<Void>
        let inputCategorySelected: BehaviorSubject<PersonalColor>
        let inputRecentSearchTable: BehaviorSubject<[String]?>
        let inputPrepatchTrigger: PublishSubject<[IndexPath]>
    }
    
    struct Output {
        let outputPostItems: Driver<[PostModel]?>
        let outputLoginView: PublishRelay<Void>
        let outputNoResult: Driver<Bool>
        
        let outputHideRecentSearch: Driver<Bool>
        let outputRecentSearchTable: PublishRelay<[String]>
        let outputMessage: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let outputPostItems = BehaviorRelay<[PostModel]?>(value: postData)
        let searchTrigger = PublishSubject<(String, PersonalColor)>()
        let outputNoResult = PublishRelay<Bool>()
        let outputHideRecentSearch = BehaviorRelay<Bool>(value: false)
        let outputRecentSearchTable = PublishRelay<[String]>()
        let outputMessage = PublishRelay<String>()
        
        Observable.combineLatest(input.inputSearchEnterTrigger, input.inputCategorySelected)
            .map{_, category in
                // 다시 초기화
                self.nextCursor = ""
                self.postData = []
                self.selectedCategory = category
            }
            .debug()
            .withLatestFrom(input.inputSearchText.orEmpty)
            .bind(with: self) { owner, value in
                searchTrigger.onNext((value, owner.selectedCategory)) // 하나라도 반응하면 네트워크 통신
                owner.categoryCases.onNext(PersonalColor.personalCases)
                if value.trimmingCharacters(in: .whitespaces) != "" {
                    // enter누르면 최근검색어 사라지게
                    outputHideRecentSearch.accept(true)
                    // userDefault에 저장...
                    UserDefaultManager.shared.saveRecentSearch(value)
                } else {
                    outputMessage.accept("검색어를 입력해주세요")
                }
            }
            .disposed(by: disposeBag)
        
        input.inputRecentSearchTable
            .bind(with: self) { owner, list in
                if let list {
                    outputRecentSearchTable.accept(list)
                } else {
                    outputRecentSearchTable.accept([])
                }
            }
            .disposed(by: disposeBag)
        
        input.inputRemoveRecent
            .bind(with: self) { owner, _ in
                UserDefaultManager.shared.removeAllRecent()
                outputRecentSearchTable.accept([])
            }
            .disposed(by: disposeBag)
        
        input.inputPrepatchTrigger
            .flatMap { indexPaths in
                let row = indexPaths.first?.row
                if row == self.postData.count - 4 || row == self.postData.count - 5 {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .debug()
            .withLatestFrom(input.inputSearchText.orEmpty)
            .bind(with: self, onNext: { owner, text in
                searchTrigger.onNext((text, owner.selectedCategory)) // 하나라도 반응하면 네트워크 통신
            })
            .disposed(by: disposeBag)
        // 네트워크 통신
        searchTrigger
            .flatMap { hashTag, category in
                if self.nextCursor == "0" {
                    return Observable<CheckPostModel>.empty()
                }
//                print("🚨\(self.nextCursor), \(category.rawValue), \(hashTag)")
                let query = HashtagQuery(next: self.nextCursor, limit: self.limit, product_id: "\(ProductId.baseProductId)\(category.rawValue)", hashTag: hashTag)
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
                owner.postData.append(contentsOf: value.data)
                outputPostItems.accept(owner.postData)

                if value.data.count == 0 {
                    outputNoResult.accept(false)
                } else {
                    outputNoResult.accept(true)
                }
                owner.nextCursor = value.next_cursor
                owner.limit = "20" // limit 다시 돌리기
            }
            .disposed(by: disposeBag)
        
        
        return Output(outputPostItems: outputPostItems.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView, outputNoResult: outputNoResult.asDriver(onErrorJustReturn: false), outputHideRecentSearch: outputHideRecentSearch.asDriver(onErrorJustReturn: false), outputRecentSearchTable: outputRecentSearchTable, outputMessage: outputMessage.asDriver(onErrorJustReturn: ""))
    }
}
