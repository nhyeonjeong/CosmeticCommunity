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
        view.tintColor = Constants.Color.point
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = Constants.Color.point.cgColor
        return view
    }()
    lazy var photoCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.register(UploadPhotosCollectionViewCell.self, forCellWithReuseIdentifier: UploadPhotosCollectionViewCell.identifier)
        view.showsVerticalScrollIndicator = false
        return view
    }()
    let titleTextField = {
        let view = UITextField()
        view.placeholder = "제목을 입력해주세요"
        return view
    }()
    let contentTextView = {
        let view = UITextView()
        view.text = "내용"
        view.font = Constants.Font.normal
        
        return view
    }()
    let personalColorPicker = {
        let view = UIPickerView()
//        view.selectedRow(inComponent: 0)
        return view
    }()
    let hashtagTextField = {
        let view = UITextField()
        view.placeholder = "해시태그를 입력해주세요. 검색에 활용됩니다."
        return view
    }()
    
    override func configureHierarchy() {
        addViews([addPhotoButton, photoCollectionView, titleTextField, contentTextView, hashtagTextField, personalColorPicker])
    }
    
    override func configureConstraints() {

        addPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.leading.equalTo(safeAreaLayoutGuide).inset(10)
            make.size.equalTo(100)
        }
        photoCollectionView.snp.makeConstraints { make in
            make.centerY.equalTo(addPhotoButton)
            make.leading.equalTo(addPhotoButton.snp.trailing)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(100)
        }
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(addPhotoButton.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerX.equalToSuperview()
        }
        personalColorPicker.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(4)
            make.height.equalTo(70)
            make.leading.equalTo(safeAreaLayoutGuide).inset(10)
            make.width.equalTo(100)
        }

        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(personalColorPicker.snp.bottom)
            make.height.equalTo(200)
            make.horizontalEdges.equalToSuperview().inset(10)
//            make.centerX.equalToSuperview()
        }
        hashtagTextField.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
    }
}

extension UploadView {
    func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.scrollDirection = .horizontal
        return layout
    }
}
