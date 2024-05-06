//
//  RegisterViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/15.
//

import UIKit
import RxCocoa
import RxSwift

final class RegisterViewController: BaseViewController {
    let mainView = RegisterView()
    let viewModel = RegisterViewModel()
    override func loadView() {
        view = mainView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavBar()
    }
    override func bind() {
        let input = RegisterViewModel.Input(inputPersonal: mainView.personalSegment.rx.selectedSegmentIndex, inputEmail: mainView.emailTextField.textField.rx.text,
                                            inputEmailCheckButtonTrigger: mainView.emailValidButton.rx.tap,
                                            inputPassword: mainView.passwordTextField.textField.rx.text,
                                            inputCheckPassword: mainView.checkPasswordTextField.textField.rx.text,
                                            inputNickname: mainView.nicknameTextField.textField.rx.text,
                                            inputRegisterButtonTrigger: mainView.registerButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        output.outputEmailMessage
            .drive(with: self) { owner, value in
                owner.mainView.emailValidMessageLabel.text = value ? "" :  "@를 포함하며 6-20자의 이메일을 작성해주세요"
                owner.mainView.emailValidMessageLabel.textColor = value ? Constants.Color.text : .red
                owner.mainView.emailValidButton.isEnabled = value ? true : false
            }.disposed(by: disposeBag)
        
        output.outputCheckEmailMessage
            .drive(with: self) { owner, value in
                owner.mainView.emailValidMessageLabel.text = value ? "사용가능한 이메일입니다." : "사용 불가능한 이메일입니다"
                owner.mainView.emailValidMessageLabel.textColor = value ? .systemGreen : .red
            }.disposed(by: disposeBag)
        
        output.outputPasswordMessage
            .drive(with: self) { owner, value in
                owner.mainView.passwordValidMessageLabel.text = value ? "" : "숫자나 영문으로 구성된 6-15자의 비밀번호를 작성해주세요"
                owner.mainView.passwordValidMessageLabel.textColor = .red
            }.disposed(by: disposeBag)
        
        output.outputNicknameMessage
            .drive(with: self) { owner, value in
                owner.mainView.nicknameValidMessageLabel.text = value ? "" : "한글이나 영문으로 구성된 5-10자리 이하의 닉네임을 작성해주세요"
                owner.mainView.nicknameValidMessageLabel.textColor = .red
            }.disposed(by: disposeBag)
        
        output.outputAlert
            .drive(with: self) { owner, message in
                owner.alert(message: message, defaultTitle: "뒤로가기") {
                    owner.navigationController?.popViewController(animated: true)
                }
            }.disposed(by: disposeBag)
        
        output.outputRegisterButtonEnabled
            .drive(with: self) { owner, valid in
                owner.mainView.registerButton.isEnabled = valid
                owner.mainView.registerButton.backgroundColor = valid ? .secondPoint : Constants.Color.gray6
            }.disposed(by: disposeBag)
        
        output.outputRegister
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true) // 다시 로그인 화면으로 넘어가기
            }.disposed(by: disposeBag)
    }
}
extension RegisterViewController {
    func configureNavBar() {
        navigationItem.title = "회원가입"
    }
}
