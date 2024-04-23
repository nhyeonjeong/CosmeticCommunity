//
//  CountButtonCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/23.
//

import UIKit

final class CountButtonView: BaseView {
    let countLabel = {
       let view = UILabel()
        view.textAlignment = .center
       view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.boldTitle)
//        view.backgroundColor = .lightGray
       return view
   }()
   lazy var label = {
       let view = UILabel()
//       view.backgroundColor = .yellow
       view.textAlignment = .center
       view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.boldTitle)
       return view
   }()
    let clearButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        return view
    }()
    override func configureHierarchy() {
        addViews([countLabel, label, clearButton])
    }
    override func configureConstraints() {
        countLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(100)
        }
        label.snp.makeConstraints { make in
            make.top.equalTo(countLabel.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalToSuperview()
            make.width.equalTo(countLabel)
            make.height.equalTo(20)
        }
        clearButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
