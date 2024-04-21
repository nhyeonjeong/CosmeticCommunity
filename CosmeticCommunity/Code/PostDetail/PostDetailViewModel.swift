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
//    var likeStatus = PublishSubject<Bool>()
    struct Input {
        let inputPostIdTrigger: PublishSubject<String>
        let inputClickLikeButtonTrigger: ControlEvent<Void>
        let inputCommentButtonTrigger: ControlEvent<Void>
        let inputCommentTextTrigger: ControlProperty<String?>
    }
    
    struct Output {
        let outputPostData: Driver<PostModel?> // PostModel정보 VC으로 전달
        let outputLoginView: Driver<Void>
        let outputLikeButton: Driver<PostModel?>
    }

    func transform(input: Input) -> Output {
        let outputPostData = PublishRelay<PostModel?>()
        let outputLoginView = PublishRelay<Void>()
        let outputLikeButton = PublishRelay<PostModel?>()
        let accessTokenTrigger = PublishSubject<Void>()
        
        
        input.inputPostIdTrigger
            .flatMap { id in
                print("포스트 조회하기")
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
                outputLikeButton.accept(value) // 버튼관련뷰에 이벤트 전달
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
                
                let newStatus = self.isClickedLikeButton(value) ? false : true
                var query = CommentQuery(like_status: newStatus)
                return self.postManager.changeLikeStatus(query, postId: self.postId)
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
            .bind(with: self) { owner, _ in
                print("버튼클릭했다")
                input.inputPostIdTrigger.onNext(owner.postId)
            }
            .disposed(by: disposeBag)

        
        input.inputCommentButtonTrigger
            .withLatestFrom(input.inputCommentTextTrigger)
            .flatMap {
                return commentManager.
            }
            .subscribe(with: self) { owner, value in
                
            }
            .disposed(by: disposeBag)
        
        return Output(outputPostData: outputPostData.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView.asDriver(onErrorJustReturn: ()), outputLikeButton: outputLikeButton.asDriver(onErrorJustReturn: nil))
    }
}

extension PostDetailViewModel {
    func isClickedLikeButton(_ postData: PostModel) -> Bool {
        return postData.likes.contains(MemberManger.shared.getUserId() ?? "") ? true : false
    }
}
