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
    var disposeBag = DisposeBag()
    var postId = ""
    struct Input {
        let inputPostIdTrigger: PublishSubject<String>
    }
    
    struct Output {
        let outputPostData: Driver<PostModel?> // PostModel정보 VC으로 전달
        let outputLoginView: Driver<Void>
    }

    func transform(input: Input) -> Output {
        let outputPostData = PublishRelay<PostModel?>()
        
        let accessTokenTrigger = PublishSubject<Void>()
        let outputLoginView = PublishRelay<Void>()
        
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
                outputPostData.accept(value)
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
                // 엑세스토큰 갱신에 성공했다면 다시 inputUploadTrigger에 이벤트전달
                MemberManger.shared.saveAccessToken(value.accessToken)
                input.inputPostIdTrigger.onNext(owner.postId)
            }
            .disposed(by: disposeBag)
        
        return Output(outputPostData: outputPostData.asDriver(onErrorJustReturn: nil), outputLoginView: outputLoginView.asDriver(onErrorJustReturn: ()))
    }
}
