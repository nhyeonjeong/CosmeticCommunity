//
//  DataView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/19.
//

import UIKit

final class PostDetailsView: BaseView {
    let stackView = UIStackView()
    let likeSymbol = {
        let view = UIImageView()
        view.image = Constants.Image.clikcedLike
        view.tintColor = Constants.Color.point
        return view
    }()
    let likeCountLabel = {
        let view = UILabel()
        view.font = Constants.Font.small
        view.textColor = Constants.Color.text
        return view
    }()
    
    let personalColorLabel = {
        let view = UILabel()
        view.textColor = Constants.Color.point
        view.font = Constants.Font.small
        view.backgroundColor = .yellow
        return view
    }()
    let skinTypeLabel = {
        let view = UILabel()
        view.textColor = Constants.Color.point
        view.font = Constants.Font.small
        view.backgroundColor = .yellow
        return view
    }()
    
    override func configureHierarchy() {
        
        stackView.addArrangedSubview(personalColorLabel)
        stackView.addArrangedSubview(skinTypeLabel)
        addViews([likeSymbol, likeCountLabel, stackView])
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
        stackView.snp.makeConstraints { make in
            make.top.equalTo(likeSymbol.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
        }
        personalColorLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(20)
        }
        skinTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(personalColorLabel.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    func upgradeView(_ item: String) {
        /*
        likeCountLabel.text = item.likes.count.formatted()
        personalColorLabel.text = item.content1
        skinTypeLabel.text = item.content2
         */
        likeCountLabel.text = item
        personalColorLabel.text = item
        skinTypeLabel.text = item
    }
}
