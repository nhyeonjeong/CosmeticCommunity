//
//  OtherProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import SnapKit

final class OtherProfileView: BaseView {
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

    let followButton = ProfileCustomButton("")
    lazy var postsCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        return view
    }()
    override func configureHierarchy() {
        followStackView.addArrangedSubview(followersCountButton)
        followStackView.addArrangedSubview(followingCountButton)

        addViews([profileView, personalLabel, followStackView, followButton, postsCollectionView])
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
            make.verticalEdges.bottom.equalToSuperview()
        }
        followButton.snp.makeConstraints { make in
            make.top.equalTo(followStackView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
            make.height.equalTo(40)
        }
        postsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(followButton.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
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
