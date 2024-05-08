//
//  NotInNetworkView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/07.
//

import UIKit
import SnapKit

final class NotInNetworkView: BaseView {
    let messageLabel = {
        let view = UILabel()
        view.text = "네트워크 상태가 좋지 않습니다\n다시 시도해주세요"
        view.numberOfLines = 2
        view.textAlignment = .center
        view.font = Constants.Font.large
        return view
    }()
    let restartButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = Constants.Image.againNetwork
        config.baseBackgroundColor = Constants.Color.subText
        config.buttonSize = .large
        view.configuration = config
        return view
    }()
    
    override func configureHierarchy() {
        addViews([messageLabel, restartButton])
    }
    override func configureConstraints() {
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(restartButton.snp.top)
        }
        restartButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    override func configureView() {
        self.backgroundColor = .white
    }
}
