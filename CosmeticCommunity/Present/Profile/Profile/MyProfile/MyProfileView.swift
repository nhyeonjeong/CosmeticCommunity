//
//  ProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import SnapKit

final class MyProfileView: BaseView {
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
    /*
    let followStackView = {
        let view = UIStackView()
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
     */
    let buttonStack = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 10
        return view
    }()
//    lazy var EditProfileButton = ProfileCustomButton(title: "프로필 수정")
    lazy var logoutButton = ProfileCustomButton(title: "로그아웃")
    
    lazy var postsCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        return view
    }()
    override func configureHierarchy() {
//        followStackView.addArrangedSubview(followersCountButton)
//        followStackView.addArrangedSubview(followingCountButton)
        
//        buttonStack.addArrangedSubview(EditProfileButton)
        buttonStack.addArrangedSubview(logoutButton)
        addViews([profileView, personalLabel, buttonStack, postsCollectionView, noResultLabel, notInNetworkView])
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
        /*
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
         */
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(personalLabel.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
            make.height.equalTo(40)
        }
        /*
        EditProfileButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
         */
        logoutButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        postsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        noResultLabel.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(20)
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
        personalLabel.text = " \(data.personalColor.rawValue) "
        personalLabel.backgroundColor = data.personalColor.backgroundColor
        
//        followersCountButton.countLabel.text = "\(data.followers.count)"
//        followingCountButton.countLabel.text = "\(data.following.count)"
    }
}
extension MyProfileView {
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
