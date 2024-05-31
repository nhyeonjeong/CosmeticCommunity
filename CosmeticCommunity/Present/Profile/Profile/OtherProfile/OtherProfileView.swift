//
//  OtherProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import SnapKit

final class OtherProfileView: BaseView {
    let notInNetworkView = {
        let view = NotInNetworkView()
        view.isHidden = true
        return view
    }()
    let noResultLabel = {
        let view = UILabel()
        view.text = "게시글이 없습니다"
        view.isHidden = true
        view.textAlignment = .center
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.large)
        return view
    }()
    let profileView = UserDataView(.profile)
    let personalLabel = {
        let view = UILabel()
        view.font = Constants.Font.normal
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
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
    let buttonStack = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 10
        return view
    }()
    let followButton = {
        let view = ProfileCustomButton(title: "팔로우")
        view.backgroundColor = Constants.Color.secondPoint
        return view
    }()
    let chattingButton = {
        let view = ProfileCustomButton(image: Constants.Image.chattingImage)
        view.tintColor = Constants.Color.point
        return view
    }()
    lazy var postsCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        return view
    }()
    override func configureHierarchy() {
        followStackView.addArrangedSubview(followersCountButton)
        followStackView.addArrangedSubview(followingCountButton)
        buttonStack.addArrangedSubview(followButton)
        buttonStack.addArrangedSubview(chattingButton)
        addViews([profileView, personalLabel, followStackView, buttonStack, postsCollectionView, noResultLabel, notInNetworkView])
    }
    override func configureConstraints() {
        profileView.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).inset(10)
        }

        personalLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileView.snp.trailing).offset(10)
            make.centerY.equalTo(profileView)
            make.height.equalTo(30)
        }
        followStackView.snp.makeConstraints { make in
            make.top.equalTo(personalLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(70)
        }
        followersCountButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
        followingCountButton.snp.makeConstraints { make in
            make.verticalEdges.bottom.equalToSuperview()
        }
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(followStackView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
            make.height.equalTo(40)
        }
        followButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
        chattingButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
        }
        postsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(followButton.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        noResultLabel.snp.makeConstraints { make in
            make.top.equalTo(followButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        notInNetworkView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
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

extension OtherProfileView {
    func collectionViewLayout() -> UICollectionViewLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
        let group: NSCollectionLayoutGroup
        if #available(iOS 16.0, *) { // 16버전 이상에서
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            print("iOS 16.0이상")
        } else {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            print("iOS 15.0이하")
        }
        group.interItemSpacing = .fixed(4) // item간의 가로 간격
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4 // 그룹간 세로 간격
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
