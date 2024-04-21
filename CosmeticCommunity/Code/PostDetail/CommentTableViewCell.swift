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
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        return view
    }()
    override func configureHierarchy() {
        contentView.addViews([commentCreatorView, createdTimeLabel, contentLabel])
    }
    override func configureConstraints() {
        commentCreatorView.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView)
        }
        createdTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentView)
            make.centerY.equalTo(commentCreatorView.snp.centerY)
            make.height.equalTo(20)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(commentCreatorView.snp.bottom)
            make.leading.equalTo(8+CreatorView.ProfileImageSize.commentCreator.rawValue)
            make.trailing.bottom.equalTo(contentView)
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
