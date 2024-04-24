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
    enum ProfileType {
        case my
        case other(userId: String)
    }

    let outputLoginView = PublishRelay<Void>()
    let postManager = PostManager()
    let likeManager = LikeManager()
    let commentManager = CommentManager()
    
    var disposeBag = DisposeBag()
    var postId = ""
    struct Input {
        let inputProfileButtonTrigger: ControlEvent<Void>
        let inputPostIdTrigger: PublishSubject<String>
        let inputClickLikeButtonTrigger: ControlEvent<Void>
        let inputCommentButtonTrigger: ControlEvent<Void>
        let inputCommentTextTrigger: ControlProperty<String?>
        let inputCommentProfileButtonTrigger: PublishSubject<Int>
        let inputCommentDeleteTrigger: PublishSubject<Int>
    }
    
    struct Output {
        let outputProfileButtonTrigger: Driver<ProfileType?>
        let outputPostData: Driver<PostModel?> // PostModel정보 VC으로 전달
        let outputLoginView: PublishRelay<Void>
        let outputLikeButton: Driver<PostModel?>
        let outputAlert: Driver<String>
        let outputNotValid: Driver<Void>
    }

    func transform(input: Input) -> Output {
        let outputProfileButtonTrigger = PublishRelay<ProfileType?>()
        let outputPostData = PublishRelay<PostModel?>()
        let outputLikeButton = PublishRelay<PostModel?>()
        let outputAlert = PublishRelay<String>()
        let outputNotValid = PublishRelay<Void>()
        let outputCommentAlert = PublishRelay<String>()
        
        let commentObservable = input.inputCommentTextTrigger.orEmpty.map { text in
            return CommentQuery(content: text)
        }
        // 선택된 셀 태그와 PostData 묶기
        let commentProfileButtonObservable = Observable.zip(input.inputCommentProfileButtonTrigger, outputPostData)
        let deleteCommentObservable = Observable.zip(input.inputCommentDeleteTrigger, outputPostData)
        
        // 프로필 버튼을 눌렀을 때
        input.inputProfileButtonTrigger
            .withLatestFrom(outputPostData)
            .bind(with: self) { owner, value in
                guard let value else {
                    return
                }
                if value.creator.user_id == UserManager.shared.getUserId() {
                    outputProfileButtonTrigger.accept(.my)
                } else {
                    outputProfileButtonTrigger.accept(.other(userId: value.creator.user_id))
                }
            }
            .disposed(by: disposeBag)
        
        input.inputCommentProfileButtonTrigger
            .withLatestFrom(commentProfileButtonObservable)
            .bind(with: self) { owner, value in
                let tag = value.0
                let commentCreatorId = value.1?.comments[tag].creator.user_id
                guard let commentCreatorId else {
                    return
                }
                // 내 프로필이라면
                if commentCreatorId == UserManager.shared.getUserId() {
                    outputProfileButtonTrigger.accept(.my)
                } else {
                    outputProfileButtonTrigger.accept(.other(userId: commentCreatorId))
                }
            }
            .disposed(by: disposeBag)
        
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
                            TokenManager.shared.accessTokenAPI {
                                input.inputPostIdTrigger.onNext(self.postId)
                            } failureHandler: {
                                outputPostData.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }

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
        
        input.inputClickLikeButtonTrigger
            .withLatestFrom(outputLikeButton)
            .debug()
            .flatMap { value in
                guard let value else {
                    outputLikeButton.accept(nil)
                    return Observable<LikeModel>.never()
                }
                // 내가 올린 게시글이라면 UI업데이트 X
                if value.creator.user_id == UserManager.shared.getUserId() {
                    outputAlert.accept(("나의 포스트는 찜 할 수 없습니다"))
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
                            TokenManager.shared.accessTokenAPI {
                                input.inputPostIdTrigger.onNext(self.postId)
                            } failureHandler: {
                                outputPostData.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }

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
                            TokenManager.shared.accessTokenAPI {
                                input.inputPostIdTrigger.onNext(self.postId)
                            } failureHandler: {
                                outputPostData.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
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
        
        // MARK: - 댓글 삭제, 수정
        input.inputCommentDeleteTrigger
            .withLatestFrom(deleteCommentObservable)
            .flatMap { (row, postData) in
                guard let postData else {
                    outputAlert.accept("댓글삭제에 실패했습니다")
                    return Observable<Void>.never()
                }
                return self.commentManager.deleteComment(postId: postData.post_id, commentId: postData.comments[row].comment_id)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputAlert.accept("댓글삭제에 실패했습니다")
                            return Observable<Void>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputCommentDeleteTrigger.onNext(row)
                            } failureHandler: {
                                //
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        outputAlert.accept("댓글삭제에 실패했습니다")
                        return Observable<Void>.never()
                    }
            }
            .subscribe(with: self) { owner, _ in
                input.inputPostIdTrigger.onNext(self.postId)
            }
            .disposed(by: disposeBag)
        
        return Output(outputProfileButtonTrigger: outputProfileButtonTrigger.asDriver(onErrorJustReturn: nil), outputPostData: outputPostData.asDriver(onErrorJustReturn: nil),
                      outputLoginView: outputLoginView,
                      outputLikeButton: outputLikeButton.asDriver(onErrorJustReturn: nil), outputAlert: outputAlert.asDriver(onErrorJustReturn: "오류가 발생했습니다"),
                      outputNotValid: outputNotValid.asDriver(onErrorJustReturn: ()))
    }
}

extension PostDetailViewModel {
    func isClickedLikeButton(_ postData: PostModel) -> Bool {
        return postData.likes.contains(UserManager.shared.getUserId() ?? "") ? true : false
    }
}
