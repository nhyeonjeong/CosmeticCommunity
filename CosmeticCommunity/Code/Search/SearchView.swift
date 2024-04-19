//
//  SearchView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import SnapKit

final class SearchView: BaseView {
    let searchTextField = {
        let view = UITextField()
        view.backgroundColor = .lightGray
        view.placeholder = "검색해주세여"
        return view
    }()
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        return view
    }()
    override func configureHierarchy() {
        addViews([searchTextField, collectionView])
    }
    override func configureConstraints() {
        searchTextField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(30)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchTextField.snp.bottom)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

extension SearchView {
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let inset: CGFloat = 10
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width-inset*3) / 2 , height: 140) // 없으면 안됨
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        layout.scrollDirection = .vertical // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
}
