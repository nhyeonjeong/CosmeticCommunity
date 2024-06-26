//
//  SearchCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/19.
//

import UIKit
import SnapKit
import Kingfisher

final class PostCollectionViewCell: BaseCollectionViewCell {
    let kingfisher = KingfisherManager.shared
    let photoImage = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.tintColor = Constants.Color.gray6
        return view
    }()
    
    let detailsView = PostDetailsView()
    
    override func configureHierarchy() {
        contentView.addViews([photoImage, detailsView])
    }
    override func configureConstraints() {
        photoImage.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
            make.height.equalTo(150)
        }
        detailsView.snp.makeConstraints { make in
            make.top.equalTo(photoImage.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(contentView)
            make.height.equalTo(40)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.contentMode = .scaleAspectFill
        photoImage.image = nil
    }
    func upgradeCell(_ item: PostModel) {
        kingfisher.getImageURL(path: item.files.first) { url in
            if let url {
                photoImage.kf.setImage(with: url, options: [.requestModifier(kingfisher.modifier)])
            } else {
                photoImage.image = UIImage(systemName: "nosign")
                photoImage.contentMode = .scaleAspectFit
            }
        }
        detailsView.upgradeView(item)
        detailsView.upgradeLikeAndCommentsCountLabel(item)
    }
}
