//
//  CategoryCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/29.
//

import UIKit
import SnapKit

final class CategoryCollectionViewCell: BaseCollectionViewCell {
    let categoryLabel = {
        let view = UILabel()
        view.font = Constants.Font.boldTitle
        view.textAlignment = .center
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addViews([categoryLabel])
    }
    override func configureConstraints() {
        categoryLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    func upgradeCell(_ personal: PersonalColor) {
        categoryLabel.text = personal.rawValue == "" ? "전체" : personal.rawValue
        categoryLabel.textColor = personal.rawValue == "" ? personal.textColor : personal.backgroundColor
    }
}
