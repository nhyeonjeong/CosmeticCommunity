//
//  RecentSearchTableViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/30.
//

import UIKit
import RxCocoa
import RxSwift

final class RecentSearchTableViewCell: BaseTableViewCell {

    var disposeBag = DisposeBag()
    
    let recentText = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        return view
    }()
    let arrowButton = {
        let view = UIButton()
        view.setImage(Constants.Image.recentSearchButton, for: .normal)
        view.tintColor = Constants.Color.text
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addViews([recentText, arrowButton])
    }
    override func configureConstraints() {
        recentText.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView).inset(10)
        }
        arrowButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.leading.equalTo(recentText.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(10)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    func upgradeCell(_ text: String) {
        recentText.text = text
    }
}
