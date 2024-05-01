//
//  TagCollectionViewCell.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/02.
//

import UIKit
import RxSwift
import RxCocoa

final class TagPostCollectionViewCell: BaseCollectionViewCell {
    let disposeBag = DisposeBag()
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.layer.cornerRadius = 10
        view.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: HomePostCollectionViewCell.identifier)
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(collectionView)
    }
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    func upgradeCell(_ postList: [PostModel]) {
        Observable.just(postList)
            .bind(to:         collectionView.rx.items(cellIdentifier: HomePostCollectionViewCell.identifier, cellType: HomePostCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
    }
}
extension TagPostCollectionViewCell {
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 200) // 없으면 안됨
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        layout.scrollDirection = .horizontal // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
}
