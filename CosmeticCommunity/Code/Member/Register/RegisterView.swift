//
//  RegisterView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/15.
//

import UIKit
import SnapKit

final class RegisterView: BaseView {
    let notInNetworkView = {
        let view = NotInNetworkView()
        view.isHidden = true
        return view
    }()
    let personalTitle = UILabel()
    let personalSegment = {
        let view = UISegmentedControl()
        view.isUserInteractionEnabled = true
        view.insertSegment(withTitle: "봄웜", at: 0, animated: true)
        view.insertSegment(withTitle: "여름쿨", at: 1, animated: true)
        view.insertSegment(withTitle: "가을웜", at: 2, animated: true)
        view.insertSegment(withTitle: "겨울쿨", at: 3, animated: true)
        view.selectedSegmentIndex = 0
        view.tintColor = Constants.Color.secondPoint
        return view
    }()
    let emailTitle = UILabel()
    let emailTextField = CustomTextField(placeholder: "이메일을 입력해주세요")
    let emailValidButton = {
        let view = UIButton()
        view.backgroundColor = Constants.Color.subText
        view.setTitle(" 중복확인 ", for: .normal)
        view.setTitleColor(Constants.Color.text, for: .normal)
        view.layer.cornerRadius = 10
        view.backgroundColor = Constants.Color.secondPoint
        return view
    }()
    let emailValidMessageLabel = {
        let view = UILabel()
        view.font = Constants.Font.small
        return view
    }()
    
    let passwordTitle = UILabel()
    let passwordTextField = CustomTextField(placeholder: "비밀번호를 입력해주세요")
    let passwordValidMessageLabel = {
        let view = UILabel()
        view.font = Constants.Font.small
        return view
    }()
    let checkPasswordTextField = CustomTextField(placeholder: "비밀번호를 다시 입력해주세요")
    
    let nicknameTitle = UILabel()
    let nicknameTextField = CustomTextField(placeholder: "닉네임을 입력해주세요")
    let nicknameValidMessageLabel = {
        let view = UILabel()
        view.font = Constants.Font.small
        return view
    }()
    let registerButton = {
        let view = PointButton()
        view.setTitle("회원가입", for: .normal)
        view.setTitleColor(Constants.Color.text, for: .normal)
        return view
    }()
    override func configureHierarchy() {
        addViews([personalTitle, personalSegment, emailTitle, passwordTitle, nicknameTitle, emailTextField, emailValidButton, emailValidMessageLabel, passwordTextField, passwordValidMessageLabel, checkPasswordTextField, nicknameTextField, nicknameValidMessageLabel, registerButton, notInNetworkView])
    }
    override func configureConstraints() {
        personalTitle.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        personalSegment.snp.makeConstraints { make in
            make.top.equalTo(personalTitle.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        emailTitle.snp.makeConstraints { make in
            make.top.equalTo(personalSegment.snp.bottom).offset(28)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTitle.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(20)
        }
        emailValidButton.snp.makeConstraints { make in
            make.leading.equalTo(emailTextField.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.centerY.equalTo(emailTextField)
        }
        emailValidMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        
        passwordTitle.snp.makeConstraints { make in
            make.top.equalTo(emailValidMessageLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTitle.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        passwordValidMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        checkPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordValidMessageLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        nicknameTitle.snp.makeConstraints { make in
            make.top.equalTo(checkPasswordTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameTitle.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        nicknameValidMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        registerButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(nicknameValidMessageLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        notInNetworkView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    override func configureView() {
        passwordTextField.textField.isSecureTextEntry = true
        checkPasswordTextField.textField.isSecureTextEntry = true // 비밀번호 입력
        settingTitleLabel(personalTitle, text: "나의 퍼스널 컬러 선택")
        settingTitleLabel(emailTitle, text: "이메일")
        settingTitleLabel(passwordTitle, text: "비밀번호")
        settingTitleLabel(nicknameTitle, text: "닉네임")
        
        emailTextField.isUserInteractionEnabled = true
    }
    func settingTitleLabel(_ label: UILabel, text: String) {
        label.text = text
        label.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
    }
}
