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
        view.configureLabel(textColor: Constants.Color.point, font: Constants.Font.boldTitle)
        return view
    }()
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(SaveCollectionViewCell.self, forCellWithReuseIdentifier: SaveCollectionViewCell.identifier)
        return view
    }()
    override func configureHierarchy() {
        addViews([title, collectionView])
    }
    override func configureConstraints() {
        title.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
    }
}

final class SaveView: BaseView {
    // NavigationBarButton커스텀버튼(프로필 이미지 패치)
    let navigationProfilebutton = {
        let view = UIButton()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()

    let likedPostsCollection = SaveCustomCollectionView()
    let recentPostsCollection = SaveCustomCollectionView()
    
    override func configureHierarchy() {
        addViews([likedPostsCollection, recentPostsCollection])
    }
    override func configureConstraints() {
        likedPostsCollection.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            
        }
        recentPostsCollection.snp.makeConstraints { make in
            make.top.equalTo(likedPostsCollection.snp.bottom).inset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
    }
    override func configureView() {
        likedPostsCollection.title.text = "하트투른 포스트"
        recentPostsCollection.title.text = "최근 본 포스트"
    }
}

extension SaveCustomCollectionView {
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 160) // 없으면 안됨
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        layout.scrollDirection = .horizontal // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
}
