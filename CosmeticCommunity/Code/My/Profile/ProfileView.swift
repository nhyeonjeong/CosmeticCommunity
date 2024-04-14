//
//  ProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import SnapKit

final class ProfileView: BaseView {
    let label = {
        let view = UILabel()
        view.text = "앎;ㅣ나얾;ㅓㄴㅇㄹ마ㅣㄴㅇㄹ"
        return view
    }()
    override func configureHierarchy() {
        addSubview(label)
    }
    override func configureConstraints() {
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
