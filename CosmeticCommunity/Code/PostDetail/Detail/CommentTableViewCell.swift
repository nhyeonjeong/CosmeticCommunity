//
//  CommentTableViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import UIKit
import SnapKit

final class CommentTableViewCell: BaseTableViewCell {
    let commentCreatorView = UserDataView(profileImageSize: .commentCreator)
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
    
    let menuButton = {

//        let view = UIMenu(image: UIImage(systemName: "ellipsis"))
        let view = UIButton()
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.tintColor = Constants.Color.point
        return view
    }()
    override func configureHierarchy() {
        contentView.addViews([commentCreatorView, createdTimeLabel, contentLabel, menuButton])
    }
    override func configureConstraints() {
        commentCreatorView.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).inset(4)
        }
        createdTimeLabel.snp.makeConstraints { make in
//            make.trailing.equalTo(contentView).inset(4)
            make.centerY.equalTo(commentCreatorView.snp.centerY)
            make.height.equalTo(20)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(commentCreatorView.snp.bottom)
            make.leading.equalTo(18+UserDataView.ProfileImageSize.commentCreator.rawValue)
            make.bottom.equalTo(contentView).inset(4)
            make.trailing.equalTo(contentView).inset(4)
//            make.height.equalTo(1)
        }
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(commentCreatorView)
            make.trailing.equalTo(contentView).inset(4)
            make.leading.equalTo(createdTimeLabel.snp.trailing).offset(2)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        // 평소에는 menubutton숨기기
        menuButton.isHidden = true
    }
    func upgradeCell(_ item: CommentModel) {
//        print(#function)
        commentCreatorView.upgradeView(profileImage: item.creator.profileImage, nick: item.creator.nick)
        createdTimeLabel.text = item.createdAt
        contentLabel.text = item.content
//        print("높이", contentLabel.frame.height)
      //  contentLabel.snp.updateConstraints { make in
        //            make.height.equalTo(contentLabel.frame.height)
        //        }
    }
}
