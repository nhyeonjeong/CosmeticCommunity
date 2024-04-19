//
//  SearchCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/19.
//

import UIKit
import SnapKit

class SearchCollectionViewCell: BaseCollectionViewCell {
    let photoImage = {
        let view = UIImageView()
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    let detailsView = PostDetailsView()
    
    override func configureHierarchy() {
        contentView.addViews([photoImage, detailsView])
    }
    override func configureConstraints() {
        photoImage.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(100)
        }
        detailsView.snp.makeConstraints { make in
            make.top.equalTo(photoImage.snp.bottom).offset(4)
            make.height.equalTo(40)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImage.image = nil
    }
    func upgradeCell(_ item: String) {
        photoImage.image = UIImage(systemName: "star")
        detailsView.upgradeView(item)
    }
    
}
