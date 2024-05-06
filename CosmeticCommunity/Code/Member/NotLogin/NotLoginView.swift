//
//  NotloginView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import SnapKit

final class NotLoginView: BaseView {
    let loginButton = {
        let view = UIButton()
        var config = UIButton.Configuration.filled()
        config.imagePadding = 10
        config.image = UIImage(systemName: "cursorarrow.rays")
        config.title = "로그인 하러 가기"
        config.baseBackgroundColor = Constants.Color.secondPoint
        config.baseForegroundColor = Constants.Color.text
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.configuration = config
        return view
    }()
    @objc func loginButtonClicked() {

    }
    override func configureHierarchy() {
        addSubview(loginButton)
    }
    override func configureConstraints() {
        loginButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
