//
//  PostImagesCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import UIKit
import SnapKit
import Kingfisher

final class PostImageCollectionViewCell: BaseCollectionViewCell {
    let kingfisher = KingfisherManager.shared
    let imageView = {
        let view = UIImageView()
        view.tintColor = Constants.Color.noImageTint
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    override func configureHierarchy() {
        contentView.addSubview(imageView)
    }
    override func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.contentMode = .scaleAspectFill
        imageView.image = nil
    }
    func upgradeCell(_ imagePath: String?) {
        kingfisher.getImageURL(path: imagePath) { url in
            if let url {
                imageView.kf.setImage(with: url, options: [.requestModifier(kingfisher.modifier)])
            } else {
                imageView.image = UIImage(systemName: "nosign")
                imageView.contentMode = .scaleAspectFit
            }
        }
    }
}
