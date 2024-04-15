//
//  LoginVIew.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/15.
//

import UIKit
import SnapKit

final class LoginView: BaseView {
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    
    let loginButton = PointButton()
    let registerButton = PointButton()
    
    override func configureHierarchy() {
        addViews([emailTextField, passwordTextField, loginButton, registerButton])
    }
    override func configureConstraints() {
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(30)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(15)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
            
        }
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
//            make.bottom.greaterThanOrEqualTo(safeAreaLayoutGuide).inset(10)
        }
    }
    override func configureView() {
        configureTextField(emailTextField, placeholer: "이메일을 입력해주세요")
        configureTextField(passwordTextField, placeholer: "비밀번호를 입력해주세요")
        loginButton.configureTitle("로그인")
        registerButton.configureTitle("회원가입")
    }
    private func configureTextField(_ view: UITextField, placeholer ph: String) {
        view.layer.cornerRadius = 10
        view.placeholder = ph
        view.layer.borderColor = Constants.Color.point.cgColor
        view.layer.borderWidth = 2
    }
}
