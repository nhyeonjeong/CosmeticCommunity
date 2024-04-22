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
        case profile = 70
        case creator = 40
        case commentCreator = 30
    }
    var profileImageSize: ProfileImageSize = .creator // 초기화
    var size: CGFloat {
        print("profileSIze", profileImageSize.rawValue)
        return profileImageSize.rawValue
    }
    let kingfisher = KingfisherManager.shared
    
    init(profileImageSize: ProfileImageSize) {
        print("init: \(profileImageSize.rawValue)")
        super.init(frame: .zero)
        self.profileImageSize = profileImageSize
//        print("profileImageSize: \(self.profileImageSize)")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func configureHierarchy() {
        addViews([profileImageView, nickname])
    }
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.size.equalTo(40)
//            DispatchQueue.main.async {
//                print("snp: \(self.profileImageSize.rawValue)")
//                make.size.equalTo(self.profileImageSize.rawValue)
//            }
            make.bottom.equalToSuperview()
        }
        nickname.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.trailing.equalToSuperview()
        }
    }
    
    func upgradeView(profileImage: String, nick: String) {
        kingfisher.getImageURL(path: profileImage) { url in
            if let url {
                profileImageView.kf.setImage(with: url)
            } else {
                profileImageView.image = Constants.Image.defulatProfileImage
            }
        }
        nickname.text = nick
    }
}
