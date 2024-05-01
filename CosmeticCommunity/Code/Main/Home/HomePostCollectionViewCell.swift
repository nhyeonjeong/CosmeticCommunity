//
//  HAhaCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/01.
//

import UIKit
import Kingfisher

final class HomePostCollectionViewCell: BaseCollectionViewCell {
    let kingfisher = KingfisherManager.shared
    let imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
    }
    override func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    func upgradeCell(_ item: PostModel) {
        kingfisher.getImageURL(path: item.files.first) { url in
            if let url {
                imageView.kf.setImage(with: url, options: [.requestModifier(kingfisher.modifier)])
            } else {
                imageView.image = UIImage(systemName: "nosign")
                imageView.contentMode = .scaleAspectFit
            }
        }
    }
}
