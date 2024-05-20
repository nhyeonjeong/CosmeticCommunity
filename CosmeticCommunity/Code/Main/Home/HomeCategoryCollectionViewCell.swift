//
//  HomeCategoryCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/19.
//

import UIKit

final class HomeCategoryCollectionViewCell: BaseCollectionViewCell {
    let rectView = {
        let view = UIView()
        view.layer.borderColor = Constants.Color.point.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 10
        return view
    }()
    let categoryLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        view.textAlignment = .center
        return view
    }()
    override func configureHierarchy() {
        rectView.addSubview(categoryLabel)
        contentView.addViews([rectView])
    }
    override func configureConstraints() {
        rectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        categoryLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20) 
        }
    }
    
    func upgradeCell(_ category: HomeViewModel.HomeCategory) {
        categoryLabel.text = category.rawValue
    }
}
