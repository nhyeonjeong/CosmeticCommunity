//
//  LoginVIew.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/15.
//

import UIKit
import SnapKit

final class LoginView: BaseView {
    let notInNetworkView = {
        let view = NotInNetworkView()
        view.isHidden = true
        return view
    }()
    let emailTextField = CustomTextField(placeholder: "이메일을 입력하세요")
    let passwordTextField = CustomTextField(placeholder: "비밀번호를 입력하세요")
        
    let loginButton = PointButton()
    let registerButton = PointButton()
    
    override func configureHierarchy() {
        addViews([emailTextField, passwordTextField, loginButton, registerButton, notInNetworkView])
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
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
            
        }
        registerButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        notInNetworkView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    override func configureView() {
        loginButton.configureTitle("로그인")
        registerButton.configureTitle("회원가입 하러가기")
    }
}
