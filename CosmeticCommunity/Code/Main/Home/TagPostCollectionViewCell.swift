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
    var disposeBag = DisposeBag()
    lazy var collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(HomePostCollectionViewCell.self, forCellWithReuseIdentifier: HomePostCollectionViewCell.identifier)
        view.isScrollEnabled = false
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
    override func configureView() {
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    func upgradeCell(_ postList: [PostModel]) {
        BehaviorSubject(value: postList)
            .bind(to: collectionView.rx.items(cellIdentifier: HomePostCollectionViewCell.identifier, cellType: HomePostCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
extension TagPostCollectionViewCell {
    func collectionViewLayout() -> UICollectionViewLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let group: NSCollectionLayoutGroup
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(2) // item간의 가로 간격
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
