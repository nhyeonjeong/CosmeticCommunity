//
//  PostDetailViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import Foundation
import RxSwift
import RxCocoa

final class PostDetailViewModel: InputOutput {
    let postManager = PostManager()
    let commentManager = CommentManager()
    
    var disposeBag = DisposeBag()
    var postId = ""
    var likeStatus = PublishSubject<Bool>()
    struct Input {
        let inputPostIdTrigger: PublishSubject<String>
        let inputClickLikeButtonTrigger: ControlEvent<Void>
    }
    
    struct Output {
        let outputPostData: Driver<PostModel?> // PostModel정보 VC으로 전달
        let outputLoginView: Driver<Void>
        let outputLikeButton: Driver<Bool?>
    }

    func transform(input: Input) -> Output {
        let outputPostData = PublishRelay<PostModel?>()
        let outputLoginView = PublishRelay<Void>()
        let outputLikeButton = PublishRelay<Bool?>()
        let accessTokenTrigger = PublishSubject<Void>()
        
        
        input.inputPostIdTrigger
            .flatMap { id in
                self.postId = id // 받아온 id 저장
                return self.postManager.checkSpecificPost(postId: id)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputPostData.accept(nil)
                            return Observable<PostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            accessTokenTrigger.onNext(())
                        }
                        outputPostData.accept(nil)
                        return Observable<PostModel>.never()
                        
                    }
            }
            .subscribe(with: self) { owner, value in
                var status = self.isClickedLikeButton(value) ? true : false
//                owner.likeStatus.onNext(newStatus)
                outputLikeButton.accept(status) // 버튼에 이벤트 전달
                outputPostData.accept(value) // 버튼제외 부분에 이벤트 전달
            }
            .disposed(by: disposeBag)
        
        accessTokenTrigger
            .flatMap {
                print("토큰 재발행 네트워크")
                return MemberManger.shared.tokenRefresh()
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputPostData.accept(nil)
                            return Observable<RefreshAccess>.never()
                        }
                        // 리프레시 토큰이 만료된거라면 로그인 화면으로...
                        if error == .refreshTokenExpired_418 {
                            outputLoginView.accept(())
                        }
                        
                        return Observable<RefreshAccess>.never()
                    }
            }
            .subscribe(with: self) { owner, value in
                input.inputPostIdTrigger.onNext(owner.postId)
            }
            .disposed(by: disposeBag)
        
        input.inputClickLikeButtonTrigger
            .withLatestFrom(outputLikeButton)
            .debug()
            .flatMap { value in
                guard let value else {
                    outputLikeButton.accept(nil)
                    return Observable<CommentModel>.never()
                }
                let newStatus = value ? false : true
                var query = CommentQuery(like_status: newStatus)

                return self.commentManager.changeLikeStatus(query, postId: self.postId)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputLikeButton.accept(nil)
                            return Observable<CommentModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            // 엑세스 토근 재발행
                            accessTokenTrigger.onNext(())
                            
                        }
                        outputLikeButton.accept(nil)
                        return Observable<CommentModel>.never()
                    }
            }
            .debug()
            .subscribe(with: self) { owner, value in
                outputLikeButton.accept(value.like_status)
            }
            .disposed(by: disposeBag)
        
        return Output(outputPostData: outputPostData.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView.asDriver(onErrorJustReturn: ()), outputLikeButton: outputLikeButton.asDriver(onErrorJustReturn: nil))
    }
}

extension PostDetailViewModel {
    func isClickedLikeButton(_ postData: PostModel?) -> Bool {
        guard let postData else {
            return false
        }
        return postData.likes.contains(MemberManger.shared.getUserId() ?? "") ? true : false
    }
}
