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
    
    var fetchCount = 0
    var tagFetchCount = 0
    var allPosts: [PostModel] = []
    var tagPosts: [[PostModel]] = [] // 2차원
    let personalCases = PersonalColor.personalCases
    var nextCursor = "0" // 결과로 가져온 다음 커서
    struct Input {
        let inputProfileImageTrigger: PublishSubject<Void>
        let inputMostLikedPostsTrigger: PublishSubject<Void>
        let inputTagSelectedTrigger: PublishSubject<String>
    }
    
    struct Output {
        let outputProfileImageTrigger: Driver<String>
        let outputMostLikedPostsItem: Driver<[PostModel]>
        let outputTagItems: Driver<[String]>
        let outputTagPostsItem: Driver<[[PostModel]]>
        let outputLoginView: PublishRelay<Void>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let outputProfileImageTrigger = PublishRelay<String>()
        let outputMostLikedPostsItem = PublishRelay<[PostModel]>()
        let outputTagItems = PublishRelay<[String]>()
        let searchPersonalCasesPost = PublishSubject<PersonalColor>()
        let outputTagPostsItem = PublishSubject<[[PostModel]]>()
        let searchTagPost = PublishSubject<(String, PersonalColor)>()
        
        input.inputProfileImageTrigger
            .subscribe(with: self) { owner, _ in
                
                let imagePath = owner.userManager.getProfileImagePath()
                outputProfileImageTrigger.accept(imagePath)
            }
            .disposed(by: disposeBag)
        
        searchPersonalCasesPost
            .flatMap { personalColor in
                let query = CheckPostQuery(next: "", limit: "100", product_id: "\(ProductId.baseProductId)\(personalColor.rawValue)")
                return self.postManager.checkPosts(query)
                    .catch { error in
                        guard let error = error as? APIError else {
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                searchPersonalCasesPost.onNext(personalColor)
                            } failureHandler: {
        //                                outputPostItems.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        return Observable<CheckPostModel>.never()
                    }
            }
            .subscribe(with: self) { owner, value in
                self.allPosts.append(contentsOf: value.data)
                owner.fetchCount += 1
                if owner.fetchCount > 3 {
                    // 정렬
                    let likeSortedList = self.allPosts.sorted { post1, post2 in
                        return post1.likes.count > post2.likes.count
                    }
                    // 태그
                    var tagDic: [String: Int] = [:]
                    for model in owner.allPosts {
                        for tag in model.hashTags {
                            if let number = tagDic[tag] {
                                tagDic[tag] = number + 1
                            } else {
                                tagDic[tag] = 0
                            }
                        }
                    }
                    let sortedTagList = tagDic.sorted { dic1, dic2 in
                        dic1.value > dic2.value
                    }.map { dic in
                        dic.key
                    }
                    
//                    print("😎\(Array(likeSortedList[..<min(24, likeSortedList.count)]))")
                    outputMostLikedPostsItem.accept(Array(likeSortedList[..<min(24, likeSortedList.count)])) // 24개까지만 가져오기
                    
                    outputTagItems.accept(Array(sortedTagList[..<min(sortedTagList.count, 5)]))
                }
            }
            .disposed(by: disposeBag)
        
        input.inputMostLikedPostsTrigger
            .bind(with: self) { owner, _ in
                for item in self.personalCases {
                    searchPersonalCasesPost.onNext(item)
                }
            }
            .disposed(by: disposeBag)
        
        searchTagPost
            .flatMap { tag, personalCase in
                let query = HashtagQuery(next: "", limit: "2", product_id: "\(ProductId.baseProductId)\(personalCase.rawValue)", hashTag: tag)
                return self.postManager.checkWithHashTag(query: query)
                    .catch { error in
                        guard let error = error as? APIError else {
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                searchTagPost.onNext((tag, personalCase))
                            } failureHandler: {
        //                                outputPostItems.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        return Observable<CheckPostModel>.never()
                    }
            }
            .debug()
            .subscribe(with: self) { owner, value in
                owner.tagFetchCount += 1
                owner.tagPosts.append(value.data)
                if owner.tagFetchCount > 3 {
                    outputTagPostsItem.onNext(owner.tagPosts)
                }
            }
            .disposed(by: disposeBag)
        
        input.inputTagSelectedTrigger
            .bind(with: self) { owner, tag in
                for item in owner.personalCases {
                    searchTagPost.onNext((tag, item))
                }
            }
            .disposed(by: disposeBag)

        return Output(outputProfileImageTrigger: outputProfileImageTrigger.asDriver(onErrorJustReturn: ""), outputMostLikedPostsItem: outputMostLikedPostsItem.asDriver(onErrorJustReturn: []), outputTagItems: outputTagItems.asDriver(onErrorJustReturn: []), outputTagPostsItem: outputTagPostsItem.asDriver(onErrorJustReturn: []), outputLoginView: outputLoginView)
    }
}
