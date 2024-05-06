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
        view.textColor = Constants.Color.subText
        return view
    }()
    let underLine = UIView()
    
    override func configureHierarchy() {
        categoryLabel.addSubview(underLine)
        contentView.addViews([categoryLabel])
    }
    override func configureConstraints() {
        categoryLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        underLine.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(2)
            make.height.equalTo(5)
        }
    }
    func upgradeCell(_ personal: PersonalColor, isSelected: Bool) {
//        categoryLabel.backgroundColor = isSelected ? Constants.Color.secondPoint : .white
        categoryLabel.textColor = isSelected ? Constants.Color.text : Constants.Color.subText
        categoryLabel.text = " \(personal.rawValue)  "
        underLine.backgroundColor = isSelected ? Constants.Color.secondPoint : .clear
    }
}
