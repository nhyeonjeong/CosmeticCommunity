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
        view.backgroundColor = Constants.Color.secondPoint
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let personalColorLabel = {
        let view = UILabel()
        view.font = Constants.Font.verySmall
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    let postTitleLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        view.numberOfLines = 2
        return view
    }()
    override func configureHierarchy() {
        contentView.addViews([postImageView, personalColorLabel, postTitleLabel])
    }
    override func configureConstraints() {
        postImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(100)
        }
        personalColorLabel.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.bottom).offset(2)
            make.height.equalTo(20)
            make.leading.equalTo(contentView)
        }
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(personalColorLabel.snp.bottom).offset(2)
            make.horizontalEdges.equalTo(contentView)
        }
        
    }
    override func configureView() {
        contentView.clipsToBounds = true
    }
    override func prepareForReuse() {
        postImageView.image = nil
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
        personalColorLabel.text = " \(item.personalColor.rawValue) "
        personalColorLabel.backgroundColor = item.personalColor.backgroundColor
        personalColorLabel.textColor = item.personalColor.textColor
    }
}
