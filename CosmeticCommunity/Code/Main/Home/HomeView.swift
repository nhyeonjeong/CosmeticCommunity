//
//  SearchView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import SnapKit

final class HomeView: BaseView {
//    let scrollView = UIScrollView()
//    let contentView = UIView()
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
        let view = UICollectionView(frame: .zero, collectionViewLayout: mostLikedcollectionViewLayout())
        view.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: HomePostCollectionViewCell.identifier)
        view.backgroundColor = .systemGreen
        view.clipsToBounds = true
        view.bounces = false
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
        let view = UICollectionView(frame: .zero, collectionViewLayout: tagPostcollectionViewLayout())
        view.register(TagPostCollectionViewCell.self, forCellWithReuseIdentifier: TagPostCollectionViewCell.identifier)
        view.backgroundColor = .systemMint
        view.clipsToBounds = true
        view.isPagingEnabled = true
        return view
    }()
    override func configureHierarchy() {
//        addSubview(scrollView)
//        scrollView.addSubview(contentView)
        addViews([likedTitleLabel, mostLikedCollectionView, tagCollectionView, tagPostCollectionView])
    }
    override func configureConstraints() {
//        scrollView.snp.makeConstraints { make in
//            make.edges.equalTo(safeAreaLayoutGuide)
//        }
//        contentView.snp.makeConstraints { make in
//            make.verticalEdges.equalTo(scrollView)
//            make.width.equalTo(scrollView.snp.width)
//        }
        likedTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(22)
        }
        mostLikedCollectionView.snp.makeConstraints { make in
            make.top.equalTo(likedTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(mostLikedCollectionView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(30)
        }
        tagPostCollectionView.snp.makeConstraints { make in
            make.top.equalTo(tagCollectionView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
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
    func mostLikedcollectionViewLayout() -> UICollectionViewLayout {
        
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(200))
        let group: NSCollectionLayoutGroup
        group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(2) // item간의 가로 간격
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
        
        
        /*
        let config = UICollectionViewCompositionalLayoutConfiguration()
        // 수평 스크롤 방향 설정
        config.scrollDirection = .horizontal
        
        // sectionProvider 클로저를 통해 각 섹션의 레이아웃을 설정
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            // 섹션에 대한 레이아웃 설정
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            // 아이템 간의 간격 설정
//            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            // 그룹 설정
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(100))
            let group: NSCollectionLayoutGroup
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // 섹션 설정
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            return section
        }, configuration: config)
        
        return layout
        */
    }
    func tagPostcollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 200) // 없으면 안됨
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
}
