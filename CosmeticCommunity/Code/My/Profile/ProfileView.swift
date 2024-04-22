//
//  ProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import SnapKit

final class ProfileView<T: ProfileProtocol>: BaseView {
    
    let profileView = UserDataView(profileImageSize: .profile)
    let personalLable = {
        let view = UILabel()
        view.font = Constants.Font.large
        return view
    }()
    lazy var countCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(CountButtonCollectionViewCell.self, forCellWithReuseIdentifier: CountButtonCollectionViewCell.identifier)
        return view
    }()
    let buttonStack = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 10
        return view
    }()
    lazy var EditProfileButton = configureButton("프로필 수정")
    lazy var logoutButton = configureButton("로그아웃")
    
    override func configureHierarchy() {
        buttonStack.addArrangedSubview(EditProfileButton)
        buttonStack.addArrangedSubview(logoutButton)
        addViews([profileView, personalLable, countCollectionView,  buttonStack])
    }
    override func configureConstraints() {
        profileView.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).inset(10)
        }

        personalLable.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(4)
            make.centerY.equalTo(profileView)
            make.height.equalTo(30)
        }

        countCollectionView.snp.makeConstraints { make in
            make.top.equalTo(personalLable.snp.bottom).offset(8)
            make.height.equalTo(50)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(countCollectionView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
            make.height.equalTo(40)
        }
        EditProfileButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
        logoutButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
        }
    }
    func upgradeView(_ data: UserModel) { // 게시글 상단부분 업데이트
        print(data)
        profileView.upgradeView(profileImage: data.profileImage, nick: data.nick)
        personalLable.textColor = data.personalColor.textColor
        personalLable.text = data.personalColor.rawValue
        personalLable.backgroundColor = data.personalColor.backgroundColor
    }
    private func configureButton(_ title: String) -> UIButton {
        let view = UIButton()
        view.setTitle(title, for: .normal)
        view.setTitleColor(Constants.Color.text, for: .normal)
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.5 // 0이 완전투명
        view.layer.shadowRadius = 2 // 얼마나 퍼지는지
        view.layer.shadowOffset = .zero // CGSize(width: 0, height: 0) 와 동일
        view.layer.masksToBounds = false
        return view
    }
}
extension ProfileView {
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 50) // 없으면 안됨
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        layout.scrollDirection = .horizontal
        return layout
    }
}


final class CountButtonCollectionViewCell: BaseCollectionViewCell {
    let countLabel = {
       let view = UILabel()
        view.textAlignment = .center
       view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.boldTitle)
        view.backgroundColor = .lightGray
       return view
   }()
   lazy var label = {
       let view = UILabel()
       view.backgroundColor = .yellow
       view.textAlignment = .center
       view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.boldTitle)
       return view
   }()
    let clearButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        return view
    }()
    let oneButtonView = UIView()
    override func configureHierarchy() {
        oneButtonView.addViews([countLabel, label, clearButton])
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



/*
 let image = Constants.Image.clickedLike
 let attachment = NSTextAttachment()
 attachment.image = image

 let attributedString = NSMutableAttributedString(string: "")
 attributedString.append(NSAttributedString(attachment: attachment))
 view.attributedText = attributedString
 */
