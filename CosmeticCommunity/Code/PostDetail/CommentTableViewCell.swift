//
//  CommentTableViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import UIKit
import SnapKit

final class CommentTableViewCell: BaseTableViewCell {

    let commentCreatorView = CreatorView(profileImageSize: .commentCreator)
    let createdTimeLabel = {
        let view = UILabel()
//        view.layer.borderColor = UIColor.red.cgColor
//        view.layer.borderWidth = 1
        view.configureLabel(textColor: Constants.Color.subText, font: Constants.Font.small)
        return view
    }()
    let contentLabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        return view
    }()
    override func configureHierarchy() {
        contentView.addViews([commentCreatorView, createdTimeLabel, contentLabel])
    }
    override func configureConstraints() {
        commentCreatorView.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).inset(4)
        }
        createdTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).inset(10)
            make.centerY.equalTo(commentCreatorView.snp.centerY)
            make.height.equalTo(20)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(commentCreatorView.snp.bottom)
            make.leading.equalTo(18+CreatorView.ProfileImageSize.commentCreator.rawValue)
            make.bottom.equalTo(contentView).inset(4)
            make.trailing.equalTo(contentView).inset(10)
        }
    }
//    override func configureView() {
//        commentCreatorView.layer.borderColor = UIColor.red.cgColor
//        commentCreatorView.layer.borderWidth = 1
//    }
    func upgradeCell(_ item: Comment) {
        commentCreatorView.upgradeView(item.creator)
        createdTimeLabel.text = item.createdAt
        contentLabel.text = item.content
    }
}
