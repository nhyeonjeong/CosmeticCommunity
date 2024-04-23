//
//  DataView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/19.
//

import UIKit

final class PostDetailsView: BaseView {
    let likeSymbol = {
        let view = UIImageView()
        view.image = Constants.Image.clickedLike
        view.tintColor = Constants.Color.point
        return view
    }()
    let likeCountLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.small)
        return view
    }()
    
    let titleLabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.boldTitle)
        return view
    }()
    
    let personalColorLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.small)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()

    override func configureHierarchy() {
        addViews([likeSymbol, likeCountLabel, titleLabel, personalColorLabel])
    }
    override func configureConstraints() {
        likeSymbol.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.size.equalTo(20)
        }
        likeCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(likeSymbol.snp.trailing).offset(4)
            make.top.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(likeSymbol.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
//            make.height.equalTo(20)
        }
        personalColorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    func upgradeView(_ item: PostModel) {
        titleLabel.text = item.title
        let text = item.personalColor.rawValue
        if let type = PersonalColor(rawValue: text) {
            personalColorLabel.text = "  \(text)  "
            personalColorLabel.textColor = type.textColor
            personalColorLabel.backgroundColor = type.backgroundColor
        }
        
    }
    func upgradeLikeCountLabel(_ likeCount: Int) {
        likeCountLabel.text = likeCount.formatted()
    }
}
