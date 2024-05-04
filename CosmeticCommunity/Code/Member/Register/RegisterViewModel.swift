//
//  ReigsterViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/15.
//

import Foundation
import RxSwift
import RxCocoa

final class RegisterViewModel: InputOutput {
    
    var outputLoginView: RxRelay.PublishRelay<Void> = PublishRelay<Void>()
    var disposeBag: DisposeBag = DisposeBag()
    let personalCases = PersonalColor.personalCases
    struct Input {
        let inputPersonal: ControlProperty<Int>
        let inputEmail: ControlProperty<String?>
        let inputEmailCheckButtonTrigger: ControlEvent<Void>
        let inputPassword: ControlProperty<String?>
        let inputCheckPassword: ControlProperty<String?>
        let inputNickname: ControlProperty<String?>
        let inputRegisterButtonTrigger: ControlEvent<Void>
    }
    
    struct Output {
        let outputEmailMessage: Driver<Bool>
        let outputCheckEmailMessage: Driver<Bool>
        let outputPasswordMessage: Driver<Bool>
        let outputNicknameMessage: Driver<Bool>
        let outputAlert: Driver<String>
        let outputRegisterButtonEnabled: Driver<Bool>
        let outputRegister: Driver<Void>
        let outputLoginView: PublishRelay<Void>
    }
    
    func transform(input: Input) -> Output {
        let outputPersonal = PublishRelay<PersonalColor>()
        let outputEmailMessage = BehaviorRelay<Bool>(value: false)
        let emailCheckSubject = PublishSubject<Void>()
        let outputCheckEmailMessage = BehaviorRelay<Bool>(value: false)
        let outputPasswordMessage = BehaviorRelay<Bool>(value: false)
        let outputNicknameMessage = BehaviorRelay<Bool>(value: false)
        let outputAlert = PublishRelay<String>()
        let outputRegisterButtonEnabled = BehaviorRelay<Bool>(value: false)
        let joinSubject = PublishSubject<Void>()
        let outputRegister = PublishRelay<Void>()
        
        // 회원가입 정보
        let joinQuery = Observable.combineLatest(input.inputEmail.orEmpty, input.inputPassword.orEmpty, input.inputNickname.orEmpty, input.inputPersonal)
            .map { values in
                let query = JoinQuery(email: values.0, password: values.1, nick: values.2, birthDay: self.personalCases[values.3].rawValue)
//                print("⭐️\(query)")
                return query
            }
        
        
        // 비밀번호를 둘 다 똑같이 썼는지
        let checkPasswordObservable = Observable.combineLatest(input.inputCheckPassword.orEmpty, input.inputPassword)
            .map { password, checkPassword in
//                print("🤬passwordCheck: \(password == checkPassword)")
                return password == checkPassword
            }
        // 유효성 검사를 모두 통과해야 회원가입버튼 활성화
        let registerValidObservable = Observable.combineLatest(outputEmailMessage, outputCheckEmailMessage,  outputPasswordMessage, checkPasswordObservable, outputNicknameMessage)
            .bind(with: self) { owner, valids in
//                print("🤬registerValidObservable : \(valids)")
                let emailValid = valids.0
                let emailCheckValid = valids.1
                let passwordValid = valids.2
                let checkPasswordValid = valids.3
                let nicknameValid = valids.4
                if emailValid && emailCheckValid && passwordValid && checkPasswordValid && nicknameValid {
                    outputRegisterButtonEnabled.accept(true)
                } else {
                    outputRegisterButtonEnabled.accept(false)
                }
            }
        
        input.inputPersonal
            .bind(with: self){ owner, index in
//                print("🤬\(index)")
                outputPersonal.accept(owner.personalCases[index])
            }.disposed(by: disposeBag)

        input.inputEmail.orEmpty
            .map{ text in
                return text.contains("@") && text.count < 21 && text.count > 5
            }
            .debug()
            .bind(with: self) { owner, valid in
                outputEmailMessage.accept(valid)
            }
            .disposed(by: disposeBag)
        
        input.inputPassword.orEmpty
            .map { text in
                let regex = "^[a-zA-Z0-9]*$"
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                return text.count < 16 && text.count > 5 && predicate.evaluate(with: text)
            }
            .bind(with: self) { owner, valid in
                outputPasswordMessage.accept(valid)
            }
            .disposed(by: disposeBag)
        
        input.inputNickname.orEmpty
            .map { text in
                let regex = "^[a-zA-Z가-힇]*$"
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                return text.count < 11 && text.count > 4 && predicate.evaluate(with: text)
            }
            .bind(with: self) { owner, valid in
                outputNicknameMessage.accept(valid)
            
            }
            .disposed(by: disposeBag)
        
        input.inputEmailCheckButtonTrigger
            .bind(to: emailCheckSubject)
            .disposed(by: disposeBag)
        
        emailCheckSubject
            .withLatestFrom(input.inputEmail.orEmpty)
            .flatMap { text in
                if text == "" { return Observable<ValidMessageModel>.empty() }
                return UserManager.shared.checkInvalidEmail(ValidEmailQuery(email: text))
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputAlert.accept("오류가 발생했습니다.")
                            return Observable<ValidMessageModel>.empty()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                emailCheckSubject.onNext(())
                            } failureHandler: {
                                //
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        } else if error == APIError.alreadyFollow_409 {
                            outputCheckEmailMessage.accept(false)
                        }
                        return Observable<ValidMessageModel>.empty()
                    }
            }
            .subscribe(with: self) { owner, message in
                outputCheckEmailMessage.accept(true)
            }
            .disposed(by: disposeBag)
        
        input.inputRegisterButtonTrigger
            .bind(to: joinSubject)
            .disposed(by: disposeBag)

        joinSubject
            .withLatestFrom(joinQuery)
            .flatMap { query in
                return UserManager.shared.join(query)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputAlert.accept("통신오류가 발생했습니다.")
                            return Observable<JoinModel>.empty()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                joinSubject.onNext(())
                            } failureHandler: {
                                //
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }else if error == APIError.alreadyFollow_409 {
                            outputAlert.accept("이미 가입한 유저입니다")
                        }
                        outputAlert.accept("통신오류가 발생했습니다")
                        return Observable<JoinModel>.empty()
                    }
            }
            .subscribe(with: self) { owner, value in
//                print("☠️\(value)")
                outputRegister.accept(())
            }.disposed(by: disposeBag)
        
        return Output(outputEmailMessage: outputEmailMessage.asDriver(onErrorJustReturn: false), outputCheckEmailMessage: outputCheckEmailMessage.asDriver(onErrorJustReturn: false), outputPasswordMessage: outputPasswordMessage.asDriver(onErrorJustReturn: false), outputNicknameMessage: outputNicknameMessage.asDriver(onErrorJustReturn: false), outputAlert: outputAlert.asDriver(onErrorJustReturn: "오류가 발생했습니다"), outputRegisterButtonEnabled: outputRegisterButtonEnabled.asDriver(onErrorJustReturn: false), outputRegister: outputRegister.asDriver(onErrorJustReturn: ()), outputLoginView: outputLoginView)
    }
}
