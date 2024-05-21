//
//  SearchView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import SnapKit

final class SearchHomeView: BaseView {
    let pickerView = {
        let view = UIPickerView()
        return view
    }()
    lazy var resultCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout())
        view.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
//        view.backgroundColor = .red
        return  view
    }()
    override func configureHierarchy() {
        addViews([pickerView, resultCollectionView])
    }
    override func configureConstraints() {
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(40)
        }
        resultCollectionView.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(10)
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
    }
}
extension SearchHomeView {
    func collectionViewLayout() -> UICollectionViewLayout {
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
