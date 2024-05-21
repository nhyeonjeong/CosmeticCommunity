//
//  HAhaCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/01.
//

import UIKit
import Kingfisher

final class HomePostLargeCollectionViewCell: BaseCollectionViewCell {
    let kingfisher = KingfisherManager.shared
    let backView = UIView()
    let imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = Constants.Color.secondPoint
        return view
    }()
    let personalLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.small)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    let titleLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.small)
        view.numberOfLines = 2
        return view
    }()
    override func configureHierarchy() {
        contentView.addSubview(backView)
        backView.addViews([imageView, personalLabel, titleLabel])
    }
    override func configureConstraints() {
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        personalLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(6)
            make.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(personalLabel.snp.bottom).offset(2)
            make.horizontalEdges.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().inset(6)
        }
    }
    override func configureView() {
        contentView.clipsToBounds = true
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
//                imageView.image = UIImage(systemName: "nosign")
                imageView.backgroundColor = Constants.Color.secondPoint
                imageView.contentMode = .scaleAspectFit
            }
        }
        personalLabel.text = " \(item.personalColor.rawValue) "
        personalLabel.textColor = item.personalColor.textColor
        personalLabel.backgroundColor = item.personalColor.backgroundColor
        titleLabel.text = item.title
    }
}
