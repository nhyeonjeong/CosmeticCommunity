//
//  CustomSheetViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CustomSheetViewModel: InputOutput {
    let postManager = PostManager()
    var outputLoginView: RxRelay.PublishRelay<Void> = PublishRelay<Void>()
    var disposeBag: DisposeBag = DisposeBag()
    struct Input {
        let inputPostId: PublishSubject<String?>
        let inputEditButtonTrigger: PublishSubject<Void>
        let inputDeletebuttonTrigger: PublishSubject<Void>
    }
    
    struct Output {
        let outputLoginView: PublishRelay<Void>
        let outputEditButton: Driver<Void?>
        let outputDeleteButton: Driver<Void?>
    }
    
    func transform(input: Input) -> Output {
        let outputEditButton = PublishRelay<Void?>()
        let outputDeleteButton = PublishRelay<Void?>()
        
        input.inputDeletebuttonTrigger
            .withLatestFrom(input.inputPostId)
            .flatMap { postId in
                print(postId)
                guard let postId else {
                    print("postId가 nil이다")
                    outputDeleteButton.accept(nil)
                    return Observable<Void>.never()
                }
                return self.postManager.deletePost(postId: postId)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputDeleteButton.accept(nil)
                            return Observable<Void>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputDeletebuttonTrigger.onNext(())
                            } failureHandler: {
//                                outputPostData.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }

                        }
                        outputDeleteButton.accept(nil)
                        return Observable<Void>.never()
                    }
            }
            .subscribe(with: self) { owner, _ in
                print("왜오래온램노애롬ㄴ애롬내올")
                outputDeleteButton.accept(())
            }
            .disposed(by: disposeBag)
        return Output(outputLoginView: outputLoginView, outputEditButton: outputEditButton.asDriver(onErrorJustReturn: nil), outputDeleteButton: outputDeleteButton.asDriver(onErrorJustReturn: nil))
    }
}
