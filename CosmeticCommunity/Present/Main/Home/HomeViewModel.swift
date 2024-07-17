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
    let outputNotInNetworkTrigger = PublishRelay<(() -> Void)?>()
    
    var fetchCount = 0
    var tagFetchCount = 0
    var allPosts: [PostModel] = []
    var tagPosts: [[PostModel]] = [] // 2차원
    var tagList: [String] = []
    var selectedTagRow: Int = 0
    let personalCases = PersonalColor.personalCases
    var nextCursor = "0" // 결과로 가져온 다음 커서
    struct Input {
        let inputProfileImageTrigger: PublishSubject<Void>
        let inputMostLikedPostsTrigger: PublishSubject<Void>
        let inputTagSelectedTrigger: PublishSubject<Int>
    }
    
    struct Output {
        let outputProfileImageTrigger: Driver<String?>
        let outputMostLikedPostsItem: Driver<[PostModel]>
        let outputTagItems: Driver<[String]>
        let outputTagPostsItem: Driver<[[PostModel]]>
        let outputLoginView: PublishRelay<Void>
        let outputNotInNetworkTrigger: PublishRelay<(() -> Void)?>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let outputProfileImageTrigger = PublishRelay<String?>()
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
                        if error == APIError.notInNetwork {
                            self.outputNotInNetworkTrigger.accept {
                                searchPersonalCasesPost.onNext(personalColor)
                            }
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
                owner.outputNotInNetworkTrigger.accept(nil)
                // 퍼스널컬러별로 100개씩 가져와서 정렬
                self.allPosts = value.data
//                self.allPosts.append(contentsOf: value.data)
                owner.fetchCount += 1
                if owner.fetchCount > 3 {
                    let likeSortedList = self.allPosts.sorted { post1, post2 in
                        return post1.likes.count > post2.likes.count
                    }
                    // 태그
                    var tagDic: [String: Int] = [:]
                    // 어떤 태그가 얼마나 있는지
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
                    outputMostLikedPostsItem.accept(Array(likeSortedList[..<min(10, likeSortedList.count)])) // 10개까지만 가져오기
                    owner.tagList = Array(sortedTagList[..<min(sortedTagList.count, 5)])
                    
                    // 만약 최근 뜨고 있는 키워드 tag가 1개 이상이라면 디폴트로 0번재 인덱스가 선택
                    print("🏂", owner.tagList)
                    if owner.tagList.count > 0 {
                        input.inputTagSelectedTrigger.onNext(owner.selectedTagRow)
                    }
                    outputTagItems.accept(owner.tagList)
//                    if owner.selectedTagRow == 0 {
//                        input.inputTagSelectedTrigger.onNext(0)
//                    }
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
                let query = HashtagQuery(next: "", limit: "50", product_id: "\(ProductId.baseProductId)\(personalCase.rawValue)", hashTag: tag)
                return self.postManager.checkWithHashTag(query: query)
                    .catch { error in
                        guard let error = error as? APIError else {
                            return Observable<CheckPostModel>.never()
                        }
                        if error == APIError.notInNetwork {
                            self.outputNotInNetworkTrigger.accept {
                                searchTagPost.onNext((tag, personalCase))
                            }
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
            .subscribe(with: self) { owner, value in
                owner.outputNotInNetworkTrigger.accept(nil)
                owner.tagFetchCount += 1
                if value.data.count != 0 {
                    let likeSortedList = value.data.sorted { post1, post2 in
                        return post1.likes.count > post2.likes.count
                    }
                    owner.tagPosts.append(Array(likeSortedList[..<min(6, likeSortedList.count)]))
                    print("😱\(owner.tagPosts)")
                }
                if owner.tagFetchCount > 3 {
                    outputTagItems.accept(owner.tagList)
                    outputTagPostsItem.onNext(owner.tagPosts)
                    owner.tagFetchCount = 0
                    owner.tagPosts = []
                }
            }
            .disposed(by: disposeBag)
        // Tag아이템을 눌렀을 때
        input.inputTagSelectedTrigger
            .bind(with: self) { owner, row in
                owner.selectedTagRow = row
                for item in owner.personalCases {
                    print("💎", row)
                    print("🥶", owner.tagList)
                    searchTagPost.onNext((owner.tagList[row], item))
                }
            }
            .disposed(by: disposeBag)
        
        return Output(outputProfileImageTrigger: outputProfileImageTrigger.asDriver(onErrorJustReturn: ""), outputMostLikedPostsItem: outputMostLikedPostsItem.asDriver(onErrorJustReturn: []), outputTagItems: outputTagItems.asDriver(onErrorJustReturn: []), outputTagPostsItem: outputTagPostsItem.asDriver(onErrorJustReturn: []), outputLoginView: outputLoginView, outputNotInNetworkTrigger: outputNotInNetworkTrigger)
    }
}



