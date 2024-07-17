//
//  CreatorView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import SnapKit
import Kingfisher

final class UserDataView: BaseView {
    let kingfisher = KingfisherManager.shared
    enum ProfileImageSize: CGFloat {
        case profile = 50
        case creator = 40
        case commentCreator = 30
    }
    
    var profileImageSize: ProfileImageSize // 초기화
    init(_ size: ProfileImageSize) {
        self.profileImageSize = size
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var size: CGFloat {
        print("profileSIze", profileImageSize.rawValue)
        return profileImageSize.rawValue
    }
    lazy var profileImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = profileImageSize.rawValue / 2
        view.clipsToBounds = true
        return view
    }()
    let nickname = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        return view
    }()
    let creatorClearButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        return view
    }()
    
    override func configureHierarchy() {
        addViews([profileImageView, nickname, creatorClearButton])
    }
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(size)
            make.bottom.equalToSuperview()
        }
        nickname.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.trailing.equalToSuperview()
        }
        creatorClearButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func upgradeView(profileImage: String, nick: String) {
//        print(#function, profileImage)
        nickname.text = nick
        if profileImage == "" {
            profileImageView.image = Constants.Image.defulatProfileImage
            return
        }
        kingfisher.getImageURL(path: profileImage) { url in
            if let url {
                print("😎url valid \(profileImage)")
                profileImageView.kf.setImage(with: url, options: [.requestModifier(kingfisher.modifier)])
            } else {
                profileImageView.image = Constants.Image.defulatProfileImage
            }
        }
    }
}
