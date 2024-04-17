//
//  UploadViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import Foundation
import RxSwift
import RxCocoa

final class UploadViewModel: InputOutput {
    let postManager = PostManager()
    struct Input {
        let inputTitleString: ControlProperty<String?>
        let inputContentString: ControlProperty<String?>
        let inputUploadButton: PublishSubject<Void>
        let inputUploadTrigger: PublishSubject<Void>
    }
    
    struct Output {
        // 글쓰기를 할 수 있는지 유효성 검사
        let outputValid: Driver<Bool>
        let outputUploadTrigger: PublishSubject<PostModel?>
        let outputLoginView: Driver<Void>

    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let outputValid = BehaviorRelay<Bool>(value: false)
        let outputUploadTrigger = PublishSubject<PostModel?>()
        let outputLoginView = PublishRelay<Void>()
        let accessTokenTrigger = PublishSubject<Void>()
        
        let postObservable = Observable.combineLatest(input.inputTitleString.orEmpty, input.inputContentString.orEmpty)
            .map { title, content in
                return PostQuery(product_id: "nhj_test", title: title, content: content, content1: "웜톤", content2: "건성", files: nil)
                
            }
        
        input.inputUploadButton
            .flatMap {
                // combineLastest대신 zip
                Observable.zip(input.inputTitleString.orEmpty, input.inputContentString.orEmpty)
            }
            .debug()
            .subscribe(with: self) { owner, value in
                let title = value.0.trimmingCharacters(in: .whitespaces)
                let content = value.1.trimmingCharacters(in: .whitespaces)
                
                if title == "" || content == ""  {
                    outputValid.accept(false)
                } else {
                    print("업로드 api통신할꺼야")
                    outputValid.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        input.inputUploadTrigger
            .withLatestFrom(postObservable)
            .flatMap { postData in
                print("업로드 네트워크")
                return self.postManager.uploadPost(postData)
                    .catch { error in
                        let error = error as! APIError
                        if error == APIError.accessTokenExpired_419 {
                            // 엑세스 토근 재발행
                            accessTokenTrigger.onNext(())
                            
                        }
                        outputUploadTrigger.onNext(nil)
                        return Observable<PostModel>.never()
                    }
            }
            .subscribe(with: self) { onwer, value in
                outputUploadTrigger.onNext(value)
            }
            .disposed(by: disposeBag)
        
        accessTokenTrigger
            .flatMap {
                print("토큰 재발행 네트워크")
                return MemberManger.shared.tokenRefresh()
                    .catch { error in
                        let error = error as! APIError
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
                input.inputUploadTrigger.onNext(())
            }
            .disposed(by: disposeBag)
        
        return Output(outputValid: outputValid.asDriver(onErrorJustReturn: false), outputUploadTrigger: outputUploadTrigger, outputLoginView: outputLoginView.asDriver(onErrorJustReturn: ()))
    }
}
