//
//  UploadView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import SnapKit

final class UploadView: BaseView {

    let addPhotoButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "camera"), for: .normal)
        view.backgroundColor = .systemGreen
        return view
    }()
    lazy var photoCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.register(UploadPhotosCollectionViewCell.self, forCellWithReuseIdentifier: UploadPhotosCollectionViewCell.identifier)
//        view.backgroundColor = .yellow
        return view
    }()
    let title = {
        let view = UITextField()
        view.placeholder = "제목"
        return view
    }()
    let content = {
        let view = UITextView()
        view.text = "내용"
        return view
    }()
    let personalColor = {
        let view = UILabel()
        view.text = "웜톤"
        return view
    }()
    let skinType = {
        let view = UILabel()
        view.text = "건성"
        return view
    }()
    
    override func configureHierarchy() {
        addViews([addPhotoButton, photoCollectionView, title, content])
    }
    
    override func configureConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(30)
            make.centerX.equalToSuperview()
        }
        content.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.height.equalTo(100)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        addPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(content.snp.bottom).offset(10)
            make.leading.equalTo(safeAreaLayoutGuide).inset(10)
            make.size.equalTo(50)
        }
        photoCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.top.equalTo(addPhotoButton.snp.bottom).offset(10)
            make.height.equalTo(100)
        }
    }
}

extension UploadView {
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        return layout
    }
}
