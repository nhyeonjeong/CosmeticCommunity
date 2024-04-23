//
//  SaveView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import SnapKit

final class SaveView: BaseView {

    let title = {
        let view = UILabel()
        view.text = "추천했던 포스트"
        view.configureLabel(textColor: Constants.Color.point, font: Constants.Font.boldTitle)
        return view
    }()
    
    lazy var collectionVeiw = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(SaveCollectionViewCell.self, forCellWithReuseIdentifier: SaveCollectionViewCell.identifier)
        return view
    }()
    override func configureHierarchy() {
        addViews([title, collectionVeiw])
    }
    override func configureConstraints() {
        title.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        collectionVeiw.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(200)
        }
    }

}

extension SaveView {
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
