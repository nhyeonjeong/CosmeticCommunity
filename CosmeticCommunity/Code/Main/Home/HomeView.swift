//
//  SearchView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import SnapKit

final class HomeView: BaseView {
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        return view
    }()
    override func configureHierarchy() {
        addSubview(collectionView)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
    }
}

extension HomeView {
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let inset: CGFloat = 10
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width-inset*3) / 2 , height: 240) // 없으면 안됨
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        layout.scrollDirection = .vertical // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
}
