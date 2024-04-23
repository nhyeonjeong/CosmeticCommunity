//
//  SaveCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import SnapKit
import Kingfisher

final class SaveCollectionViewCell: BaseCollectionViewCell {
    let kingfisherManager = KingfisherManager.shared
    let postImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    let postTitleLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        view.numberOfLines = 0
        return view
    }()
    
    let personalColorLabel = {
        let view = UILabel()
        view.font = Constants.Font.normal
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addViews([postImageView, postTitleLabel, personalColorLabel])
    }
    override func configureConstraints() {
        postImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(170)
        }
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(contentView)
            make.height.equalTo(20)
        }
        personalColorLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(2)
            make.height.equalTo(20)
            make.bottom.horizontalEdges.equalTo(contentView)
        }
        
    }
    func upgradeCell(_ item: PostModel) {
        kingfisherManager.getImageURL(path: item.files.first) { url in
            if let url {
                postImageView.kf.setImage(with: url, options: [.requestModifier(kingfisherManager.modifier)])
            } else {
                postImageView.backgroundColor = .lightGray
            }
        }
        postTitleLabel.text = item.title
        personalColorLabel.text = item.personalColor.rawValue
        personalColorLabel.backgroundColor = item.personalColor.backgroundColor
        personalColorLabel.textColor = item.personalColor.textColor
    }
}
