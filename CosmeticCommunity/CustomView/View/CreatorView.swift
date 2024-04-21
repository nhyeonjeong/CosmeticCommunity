//
//  CreatorView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import SnapKit
import Kingfisher

final class CreatorView: BaseView {
    let kingfisher = KingfisherManager.shared
    let profileImage = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    let nickname = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        return view
    }()
    
    override func configureHierarchy() {
        addViews([profileImage, nickname])
    }
    override func configureConstraints() {
        profileImage.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(40)
        }
        nickname.snp.makeConstraints { make in
            make.leading.equalTo(profileImage.snp.trailing).offset(8)
            make.centerY.equalTo(profileImage.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }
    
    func upgradeView(_ item: Creator) {
        kingfisher.getImageURL(path: item.profileImage) { url in
            if let url {
                profileImage.kf.setImage(with: url)
            } else {
                profileImage.image = Constants.Image.defulatProfileImage
            }
        }
        nickname.text = item.nick
    }
}
