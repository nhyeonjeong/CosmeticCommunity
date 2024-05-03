//
//  HomeTagCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/02.
//

import UIKit
import SnapKit
// 태그
final class HomeTagCollectionViewCell: BaseCollectionViewCell {
    let tagLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    override func configureHierarchy() {
        contentView.addSubview(tagLabel)
    }
    override func configureConstraints() {
        tagLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    override func configureView() {
        contentView.layer.cornerRadius = 10
    }
    func upgradeCell(_ text: String) {
        tagLabel.text = "  # \(text)  "
    }
}
