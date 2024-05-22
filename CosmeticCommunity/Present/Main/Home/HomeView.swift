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
    let usedItemButton = {
        let view = UIButton()
        view.setTitle("중고 상품 구매하러 가기 >", for: .normal)
        view.setTitleColor(Constants.Color.text, for: .normal)
        view.layer.borderColor = Constants.Color.subText.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    let notInNetworkView = {
        let view = NotInNetworkView()
        view.isHidden = true
        return view
    }()
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
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.bigTitle)
        return view
    }()
    lazy var mostLikedCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: mostLikedcollectionViewLayout())
        view.register(HomePostLargeCollectionViewCell.self, forCellWithReuseIdentifier: HomePostLargeCollectionViewCell.identifier)
        view.clipsToBounds = true
        view.bounces = false
        return view
    }()
    let tagTitleLabel = {
        let view = UILabel()
        view.text = "최근 뜨고 있는 키워드"
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.bigTitle)
        return view
    }()
    lazy var tagCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.tagCollectionViewLayout())
        view.register(HomeTagCollectionViewCell.self, forCellWithReuseIdentifier: HomeTagCollectionViewCell.identifier)
        view.alwaysBounceVertical = false
        return view
    }()
    lazy var tagPostCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: tagPostcollectionViewLayout())
        view.register(TagPostCollectionViewCell.self, forCellWithReuseIdentifier: TagPostCollectionViewCell.identifier)
        view.clipsToBounds = true
        view.isPagingEnabled = true
        return view
    }()
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addViews([usedItemButton, likedTitleLabel, mostLikedCollectionView, tagTitleLabel, tagCollectionView, tagPostCollectionView, notInNetworkView])
    }
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        usedItemButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(40)
        }
        likedTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(usedItemButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().inset(10)
            make.height.equalTo(22)
        }
        mostLikedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(likedTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(250)
        }
        tagTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(mostLikedCollectionView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(22)
        }
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(tagTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
        }
        tagPostCollectionView.snp.makeConstraints { make in
            make.top.equalTo(tagCollectionView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(240)
            make.bottom.equalTo(contentView).inset(10)
        }
        notInNetworkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
    func mostLikedcollectionViewLayout() -> UICollectionViewLayout {
        
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.40), heightDimension: .absolute(250))
        let group: NSCollectionLayoutGroup
        group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(2) // item간의 가로 간격
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }
    func tagPostcollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 240) // 없으면 안됨
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        return layout
    }
}
