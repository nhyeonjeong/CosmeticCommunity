//
//  SearchView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/28.
//

import UIKit

final class SearchView: BaseView {
    let textfield = {
        let view = UITextField()
        view.placeholder = "검색어를 입력해주세요"
        return view
    }()
    let xButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        view.tintColor = Constants.Color.subText
        return view
    }()
    let categoryTitleLabel = {
        let view = UILabel()
        view.text = "카테고리 |"
        view.textColor = Constants.Color.point
        return view
    }()
    lazy var categoryCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.categoryCollectionViewLayout())
        view.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
//        view.backgroundColor = .yellow
        view.showsVerticalScrollIndicator = false
        return view
    }()
    lazy var resultCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.resultCollectionViewLayout())
        view.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        view.backgroundColor = .red
        return  view
    }()
    override func configureHierarchy() {
        textfield.addSubview(xButton)
        addViews([categoryTitleLabel, categoryCollectionView, resultCollectionView])
    }
    override func configureConstraints() {
        categoryTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(safeAreaLayoutGuide).inset(10)
        }
        categoryCollectionView.snp.makeConstraints { make in
            make.centerY.equalTo(categoryTitleLabel)
            make.leading.equalTo(categoryTitleLabel.snp.trailing).offset(4)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
        resultCollectionView.snp.makeConstraints { make in
            make.top.equalTo(categoryTitleLabel.snp.bottom).offset(10)
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
    }
}
extension SearchView {
    func categoryCollectionViewLayout() -> UICollectionViewLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(10), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let group: NSCollectionLayoutGroup
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(20) // item간의 가로 간격
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
    func resultCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let inset: CGFloat = 10
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width-inset*3) / 2 , height: 240) // 없으면 안됨
        layout.minimumLineSpacing = 10 // 세로간
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        layout.scrollDirection = .vertical // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
}
