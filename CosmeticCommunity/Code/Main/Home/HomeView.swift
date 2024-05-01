//
//  SearchView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import SnapKit

final class HomeView: BaseView {
    let scrollView = UIScrollView()
    let contentView = UIView()
    // NavigationBarButton커스텀버튼(프로필 이미지 패치)
    let navigationProfilebutton = {
        let view = UIButton()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    
    let likedTitleLabel = {
        let view = UILabel()
        view.text = "최근 인기있는 상품"
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.boldTitle)
        return view
    }()
    lazy var mostLikedCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: HomePostCollectionViewCell.identifier)
        view.layer.cornerRadius = 10
        view.backgroundColor = .systemGreen
        view.clipsToBounds = true
        return view
    }()
    
    let tagTitleLabel = {
        let view = UILabel()
        view.text = ""
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.boldTitle)
        return view
    }
    lazy var tagCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.tagCollectionViewLayout())
        view.register(HomeTagCollectionViewCell.self, forCellWithReuseIdentifier: HomeTagCollectionViewCell.identifier)
        return view
    }()
    lazy var tagPostCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: HomePostCollectionViewCell.identifier)
        view.layer.cornerRadius = 10
        view.backgroundColor = .systemMint
        view.clipsToBounds = true
        return view
    }()
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addViews([likedTitleLabel, mostLikedCollectionView, tagCollectionView, tagPostCollectionView])
    }
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(scrollView)
            make.width.equalTo(scrollView.snp.width)
        }
        likedTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).inset(10)
            make.height.equalTo(22)
        }
        mostLikedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(likedTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(10)
            make.height.equalTo(200)
        }
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(mostLikedCollectionView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(30)
        }
        tagPostCollectionView.snp.makeConstraints { make in
            make.top.equalTo(tagCollectionView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(200)
        }
    }
}

extension HomeView {
    func tagCollectionViewLayout() -> UICollectionViewLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(10), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(30))
        let group: NSCollectionLayoutGroup
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(5)
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        section.interGroupSpacing = 5
        return UICollectionViewCompositionalLayout(section: section)
    }
    func collectionViewLayout() -> UICollectionViewLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .absolute(200))
        let group: NSCollectionLayoutGroup
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(4) // item간의 가로 간격
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
