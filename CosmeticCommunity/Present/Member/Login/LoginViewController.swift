//
//  LoginViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/15.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController {
    let mainView = LoginView()
    let viewModel = LoginViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    deinit {
        print("LoginViewCon Deinit")
    }
    
    override func bind() {
        let input = LoginViewModel.Input(inputLoginButton: mainView.loginButton.rx.tap,
                                         inputEmailTextField: mainView.emailTextField.textField.rx.text,
                                         inputPasswordTextField: mainView.passwordTextField.textField.rx.text)
        
        let output = viewModel.transform(input: input)
        outputNotInNetworkTrigger = output.outputNotInNetworkTrigger
        // 로그인버튼
        output.outputLoginButton
            .bind(with: self) { owner, value in
                if let _ = value {
                    owner.dismiss(animated: true)
                    owner.navigationController?.pushViewController(RegisterViewController(), animated: true)
                    owner.mainView.loginButton.setTitle("로그인", for: .normal)
                } else {
                    owner.mainView.loginButton.setTitle("로그인 정보가 맞지 않습니다", for: .normal)
                }
            }
            .disposed(by: disposeBag)
        // 회원가입버튼
        mainView.registerButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(RegisterViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        
        // MARK: - Network
        // 새로고침 버튼 tap
        mainView.notInNetworkView.restartButton.rx.tap
            .withLatestFrom(viewModel.outputNotInNetworkTrigger)
            .debug()
            .bind(with: self) { owner, againFunc in
                againFunc?()
            }.disposed(by: disposeBag)
        
        outputNotInNetworkTrigger
            .asDriver(onErrorJustReturn: {})
            .drive(with: self) { owner, value in
                if let value {
                    owner.mainView.notInNetworkView.isHidden = false
                } else {
                    owner.mainView.notInNetworkView.isHidden = true // 네트워크 연결되었음
                }
            }.disposed(by: disposeBag)
    }
}
