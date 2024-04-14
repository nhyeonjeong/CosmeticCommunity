//
//  NotloginView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import SnapKit

final class NotloginView: BaseView {
    private let loginButton = {
        let view = UIButton()
        view.setTitle("로그인 하러 가기 >", for: .normal)
        view.setTitleColor(Constants.Color.message, for: .normal)
        return view
    }()
    override func configureHierarchy() {
        addSubview(loginButton)
    }
    override func configureConstraints() {
        loginButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
