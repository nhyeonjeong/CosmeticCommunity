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
    let likeManager = LikeManager()
    let commentManager = CommentManager()
    
    var disposeBag = DisposeBag()
    var postId = ""
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
        let outputNotValid: Driver<Void>
//        let outputCommentButtonTrigger: Driver<Void>
    }

    func transform(input: Input) -> Output {
        let outputPostData = PublishRelay<PostModel?>()
        let outputLoginView = PublishRelay<Void>()
        let outputLikeButton = PublishRelay<PostModel?>()
        let outputNotValid = PublishRelay<Void>()
        let accessTokenTrigger = PublishSubject<Void>()
        
        let commentObservable = input.inputCommentTextTrigger.orEmpty.map { text in
            return CommentQuery(content: text)
        }
        
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
                            return Observable<RefreshAccessModel>.never()
                        }
                        // 리프레시 토큰이 만료된거라면 로그인 화면으로...
                        if error == .refreshTokenExpired_418 {
                            outputLoginView.accept(())
                        }
                        
                        return Observable<RefreshAccessModel>.never()
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
                    return Observable<LikeModel>.never()
                }
                
                let newStatus = self.isClickedLikeButton(value) ? false : true
                let query = LikeQuery(like_status: newStatus)
                return self.likeManager.changeLikeStatus(query, postId: self.postId)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputLikeButton.accept(nil)
                            return Observable<LikeModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            // 엑세스 토근 재발행
                            accessTokenTrigger.onNext(())

                        }
                        outputLikeButton.accept(nil)
                        return Observable<LikeModel>.never()
                    }
            }
            .bind(with: self) { owner, _ in
                print("버튼클릭했다")
                input.inputPostIdTrigger.onNext(owner.postId)
            }
            .disposed(by: disposeBag)

        
        input.inputCommentButtonTrigger
            .withLatestFrom(commentObservable)
            .flatMap { query in
                if query.content.trimmingCharacters(in: .whitespaces) == "" {
                    // 비어있으면 댓글 입력하지 말기
                    print("비어있음")
                    outputNotValid.accept(())
                    return Observable<CommentModel>.never()
                }
                return self.commentManager.uploadComment(query, postId: self.postId)
                    .catch { error in
                        guard let error = error as? APIError else {
                            return Observable<CommentModel>.never()
                        }
                        // 리프레시 토큰이 만료된거라면 로그인 화면으로...
                        if error == APIError.accessTokenExpired_419 {
                            // 엑세스 토근 재발행
                            accessTokenTrigger.onNext(())
                            
                        }
                        print(error.errorMessage)
                        return Observable<CommentModel>.never()
                    }
            }
            .subscribe(with: self) { owner, vaue in
                print("댓글 업로드 api통신 성공")
                input.inputPostIdTrigger.onNext(owner.postId)
            }
            .disposed(by: disposeBag)
        
        return Output(outputPostData: outputPostData.asDriver(onErrorJustReturn: nil),
                      outputLoginView: outputLoginView.asDriver(onErrorJustReturn: ()),
                      outputLikeButton: outputLikeButton.asDriver(onErrorJustReturn: nil),
                      outputNotValid: outputNotValid.asDriver(onErrorJustReturn: ()))
    }
}

extension PostDetailViewModel {
    func isClickedLikeButton(_ postData: PostModel) -> Bool {
        return postData.likes.contains(MemberManger.shared.getUserId() ?? "") ? true : false
    }
}
