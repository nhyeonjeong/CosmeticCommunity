//
//  LoginViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/15.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: InputOutput {

    struct Input {
        let inputLoginButton: ControlEvent<Void>
        let inputEmailTextField: ControlProperty<String?>
        let inputPasswordTextField: ControlProperty<String?>
    }
    struct Output {
        let outputLoginButton: PublishSubject<LoginModel?>
    }
    var disposeBag = DisposeBag()
    let outputLoginView = PublishRelay<Void>()
    
    func transform(input: Input) -> Output {
        let outputLoginButton = PublishSubject<LoginModel?>()
        
        let loginObservable = Observable.combineLatest(input.inputEmailTextField.orEmpty, input.inputPasswordTextField.orEmpty) // 두 가지를 비교
            .map{ email, password in
                //map을 통해 네트워크 통신 후 반환
                print(email, password)
                return LoginQuery(email: email, password: password)
            }
        
        input.inputLoginButton
            .withLatestFrom(loginObservable)
            .flatMap { loginData in
                UserManager.shared.login(loginData)
                    .catch({ error in
                        let error = error as! APIError
                        print(error.errorMessage)
                        outputLoginButton.onNext(nil)
                        return Observable<LoginModel>.never()
                    })
            }
            .subscribe(with: self, onNext: { owner, value in
                outputLoginButton.onNext(value)
            })
            .disposed(by: disposeBag)
        
        return Output(outputLoginButton: outputLoginButton)
    }
}
