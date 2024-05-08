//
//  SaveView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import SnapKit

// 컴스텀 뷰
final class SaveCustomCollectionView: BaseView {
    let title = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.bigTitle)
        return view
    }()
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(SaveCollectionViewCell.self, forCellWithReuseIdentifier: SaveCollectionViewCell.identifier)
        view.layer.cornerRadius = 10
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = false
        return view
    }()
    override func configureHierarchy() {
        addViews([title, collectionView])
    }
    override func configureConstraints() {
        title.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).inset(10)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(320)
        }
    }
}

final class SaveView: BaseView {
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
    let scrollView = {
        let view = UIScrollView()
//        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .onDrag
        return view
    }()
    let contentView = UIView()
    let likedPostsCollection = SaveCustomCollectionView()
    let recentPostsCollection = SaveCustomCollectionView()
    
    override func configureHierarchy() {
        contentView.addViews([likedPostsCollection, recentPostsCollection])
        scrollView.addSubview(contentView)
        addViews([scrollView, notInNetworkView])
    }
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        likedPostsCollection.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.horizontalEdges.equalToSuperview()
            
        }
        recentPostsCollection.snp.makeConstraints { make in
            make.top.equalTo(likedPostsCollection.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
        }
        notInNetworkView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    override func configureView() {
        likedPostsCollection.title.text = "추천누른 게시글"
        recentPostsCollection.title.text = "최근 본 게시글"
    }
}

extension SaveCustomCollectionView {
    func collectionViewLayout() -> UICollectionViewLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(320))
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
}
