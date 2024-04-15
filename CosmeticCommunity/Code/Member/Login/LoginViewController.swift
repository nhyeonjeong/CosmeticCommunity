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
    let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    override func bind() {
        let input = LoginViewModel.Input(inputLoginButton: mainView.loginButton.rx.tap,
                                         inputEmailTextField: mainView.emailTextField.rx.text,
                                         inputPasswordTextField: mainView.passwordTextField.rx.text)
        
        let output = viewModel.transform(input: input)
        // 로그인버튼
        output.outputLoginButton
            .bind(with: self) { owner, value in
                if value {
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
    }
    
// contenttype, sesackey 필수라고요?
}
