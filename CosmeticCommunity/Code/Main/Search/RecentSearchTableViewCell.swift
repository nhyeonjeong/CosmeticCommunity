//
//  RecentSearchTableViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/30.
//

import UIKit

final class RecentSearchTableViewCell: BaseTableViewCell {

    let recentText = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        return view
    }()
    let xButton = {
        let view = UIButton()
        view.setImage(Constants.Image.xButton, for: .normal)
        view.tintColor = Constants.Color.text
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addViews([recentText, xButton])
    }
    override func configureConstraints() {
        recentText.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).inset(10)
        }
        xButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(recentText.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(10)
        }
    }
    func upgradeCell(_ text: String) {
        recentText.text = text
    }
}
