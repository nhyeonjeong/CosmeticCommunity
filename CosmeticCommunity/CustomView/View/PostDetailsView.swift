//
//  DataView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/19.
//

import UIKit

final class PostDetailsView: BaseView {
    let likeAndCommentsCountLabel = {
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
        addViews([likeAndCommentsCountLabel, titleLabel, personalColorLabel])
    }
    override func configureConstraints() {
        likeAndCommentsCountLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(likeAndCommentsCountLabel.snp.bottom).offset(4)
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
        if let type = PersonalColor(rawValue: item.personalColor.rawValue) {
            personalColorLabel.text = "  \(text)  "
            personalColorLabel.textColor = type.textColor
            personalColorLabel.backgroundColor = type.backgroundColor
        }
        
    }
    func upgradeLikeAndCommentsCountLabel(_ item: PostModel) {
        let text = "추천 \(item.likes.count.formatted()) | 댓글 \(item.comments.count.formatted())"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.font, value: Constants.Font.smallTitle, range: (text as NSString).range(of: "\(item.likes.count)개"))
        attributedString.addAttribute(.font, value: Constants.Font.smallTitle, range: (text as NSString).range(of: "\(item.comments.count)개"))
        likeAndCommentsCountLabel.attributedText = attributedString
    }
}
