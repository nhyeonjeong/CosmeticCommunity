//
//  HomePostNormalCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/05.
//

import UIKit
import SnapKit
import Kingfisher

class HomePostNormalCollectionViewCell: BaseCollectionViewCell {
    let kingfisher = KingfisherManager.shared
    let imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    let personalLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.small)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    /*
    let titleLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.small)
        view.numberOfLines = 2
        return view
    }()
     */
    override func configureHierarchy() {
        contentView.addViews([imageView, personalLabel])
    }
    override func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        personalLabel.snp.makeConstraints { make in
//            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.equalTo(contentView).inset(6)
            make.height.equalTo(20)
            make.bottom.equalTo(contentView).inset(6)
        }
        /*
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(personalLabel.snp.bottom).offset(2)
            make.bottom.horizontalEdges.equalTo(contentView).inset(6)
        }
         */
    }
    override func configureView() {
        contentView.clipsToBounds = true
        contentView.backgroundColor = Constants.Color.secondPoint
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    func upgradeCell(_ item: PostModel) {
        kingfisher.getImageURL(path: item.files.first) { url in
            if let url {
                imageView.kf.setImage(with: url, options: [.requestModifier(kingfisher.modifier)])
            } else {
                imageView.backgroundColor = Constants.Color.secondPoint
//                imageView.contentMode = .scaleAspectFit
            }
        }
        personalLabel.text = " \(item.personalColor.rawValue) "
        personalLabel.textColor = item.personalColor.textColor
        personalLabel.backgroundColor = item.personalColor.backgroundColor
//        titleLabel.text = item.title
    }
}
