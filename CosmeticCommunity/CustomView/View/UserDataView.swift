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
    enum ProfileImageSize: CGFloat {
        case creator = 40
        case commentCreator = 30
    }
    var profileImageSize: CGFloat = ProfileImageSize.commentCreator.rawValue
    let kingfisher = KingfisherManager.shared
    
    init(profileImageSize: ProfileImageSize) { // 디폴트 30
        super.init(frame: .zero)
        self.profileImageSize = profileImageSize.rawValue
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var profileImage = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = profileImageSize / 2
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
            make.size.equalTo(profileImageSize)
            make.bottom.equalToSuperview()
        }
        nickname.snp.makeConstraints { make in
            make.leading.equalTo(profileImage.snp.trailing).offset(8)
            make.centerY.equalTo(profileImage.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }
    
    func upgradeView(_ item: CreatorModel) {
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
