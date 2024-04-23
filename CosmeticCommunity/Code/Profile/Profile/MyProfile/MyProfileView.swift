//
//  ProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import SnapKit

final class MyProfileView: BaseView {
    
    let profileView = UserDataView(profileImageSize: .profile)
    let personalLabel = {
        let view = UILabel()
        view.font = Constants.Font.large
        return view
    }()
    let followStackView = {
        let view = UIStackView()
//        view.spacing = 10
        view.distribution = .fillEqually
        view.axis = .horizontal
        return view
    }()
    let followersCountButton = {
        let view = CountButtonView()
        view.countLabel.text = "0"
        view.label.text = "팔로워"
        return view
    }()
    let followingCountButton = {
        let view = CountButtonView()
        view.countLabel.text = "0"
        view.label.text = "팔로잉"
        return view
    }()
    let likePostsButton = {
        let view = CountButtonView()
        view.label.text = "하트누른 게시글"
        let image = Constants.Image.clickedLike
        let attachment = NSTextAttachment()
        attachment.image = image

        let attributedString = NSMutableAttributedString(string: "")
        attributedString.append(NSAttributedString(attachment: attachment))
        view.countLabel.attributedText = attributedString
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
    
    lazy var postsCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        return view
    }()
    override func configureHierarchy() {
        followStackView.addArrangedSubview(followersCountButton)
        followStackView.addArrangedSubview(followingCountButton)
        followStackView.addArrangedSubview(likePostsButton)
        
        buttonStack.addArrangedSubview(EditProfileButton)
        buttonStack.addArrangedSubview(logoutButton)
        addViews([profileView, personalLabel, followStackView, buttonStack, postsCollectionView])
    }
    override func configureConstraints() {
        profileView.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).inset(10)
        }

        personalLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(4)
            make.centerY.equalTo(profileView)
            make.height.equalTo(30)
        }
        followStackView.snp.makeConstraints { make in
            make.top.equalTo(personalLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(70)
        }
        followersCountButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
        followingCountButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
        }
        likePostsButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
        }
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(followStackView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
            make.height.equalTo(40)
        }
        EditProfileButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
        logoutButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
        }
        postsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    func upgradeUserView(_ data: UserModel) { // 게시글 상단부분 업데이트
        print(data)
        profileView.upgradeView(profileImage: data.profileImage, nick: data.nick)
        personalLabel.textColor = data.personalColor.textColor
        personalLabel.text = data.personalColor.rawValue
        personalLabel.backgroundColor = data.personalColor.backgroundColor
        
        followersCountButton.countLabel.text = "\(data.followers.count)"
        followingCountButton.countLabel.text = "\(data.following.count)"
    }
}
extension MyProfileView {
    func collectionViewLayout() -> UICollectionViewLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group: NSCollectionLayoutGroup
        if #available(iOS 16.0, *) { // 16버전 이상에서
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            print("iOS 16.0이상")
        } else {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            print("iOS 15.0이하")
        }
        group.interItemSpacing = .fixed(4) // item간의 가로 간격
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4 // 그룹간 세로 간격
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
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
