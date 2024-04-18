//
//  UploadPhotosCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/18.
//

import UIKit
import SnapKit

final class UploadPhotosCollectionViewCell: BaseCollectionViewCell {
    let photoImage = {
        let view = UIImageView(frame: .zero)
        view.layer.cornerRadius = 10
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    let xButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: Constants.Image.xButton), for: .normal)
        view.layer.cornerRadius = 20
        view.tintColor = Constants.Color.point
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addViews([photoImage, xButton])
    }
    override func configureConstraints() {
        photoImage.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        xButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(40)
        }
    }
    
    func upgradeCell(_ item: NSItemProviderReading) {
        photoImage.image = item as? UIImage
    }
}
