//
//  UploadView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import SnapKit

final class UploadView: BaseView {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let notInNetworkView = {
        let view = NotInNetworkView()
        view.isHidden = true
        return view
    }()
    let switchBackgroundView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    let switchMessage = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        view.text = "중고로 올리는 게시물입니다."
        return view
    }()
    let usedItemPostSwitch = UISwitch()
    let addPhotoButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "camera"), for: .normal)
        view.backgroundColor = Constants.Color.secondPoint
        view.tintColor = Constants.Color.text
        view.layer.cornerRadius = 10
        var config = UIButton.Configuration.plain()
        config.buttonSize = .large
        view.configuration = config
        return view
    }()
    lazy var photoCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        view.register(UploadPhotosCollectionViewCell.self, forCellWithReuseIdentifier: UploadPhotosCollectionViewCell.identifier)
        view.showsVerticalScrollIndicator = false
        return view
    }()
    let titleTextField = {
        let view = CustomTextField(placeholder: "제목을 입력해주세요")
        view.placeholder = "제목을 입력해주세요"
        view.textField.font = Constants.Font.normal
        return view
    }()
    let contentBackView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderColor = Constants.Color.secondPoint.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    let contentTextView = {
        let view = UITextView()
        view.font = Constants.Font.normal
        return view
    }()
    let personalSelectButton = {
        let view = UIButton()
        var config = UIButton.Configuration.filled()
        config.image = Constants.Image.cursorClickImage
        config.imagePadding = 5
        config.imagePlacement = .trailing
        config.title = "상품의 퍼스널 컬러를 선택해주세요"
        config.baseBackgroundColor = Constants.Color.secondPoint
        config.baseForegroundColor = Constants.Color.text
        view.configuration = config
        view.layer.cornerRadius = 10
        return view
    }()
    
    let hashtagTextField = {
        let view = CustomTextField(placeholder: "해시태그를 입력해주세요! 검색에 활용됩니다")
        view.placeholder = "해시태그를 입력해주세요. 검색에 활용됩니다."
        view.textField.font = Constants.Font.normal
        return view
    }()
    let button = {
        let view = PointButton()
        return view
    }()
    
    override func configureHierarchy() {
        addViews([scrollView, button])
        scrollView.addSubview(contentView)
        contentBackView.addSubview(contentTextView)
        switchBackgroundView.addViews([switchMessage, usedItemPostSwitch])
        contentView.addViews([switchBackgroundView, addPhotoButton, photoCollectionView, titleTextField, personalSelectButton, contentBackView, hashtagTextField, notInNetworkView])
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        switchBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview()
        }
        switchMessage.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
        }
        usedItemPostSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
        }
        addPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(switchBackgroundView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(10)
            make.size.equalTo(100)
        }
        photoCollectionView.snp.makeConstraints { make in
            make.centerY.equalTo(addPhotoButton)
            make.leading.equalTo(addPhotoButton.snp.trailing)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(100)
        }
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(addPhotoButton.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        personalSelectButton.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        contentBackView.snp.makeConstraints { make in
            make.top.equalTo(personalSelectButton.snp.bottom).offset(8)
            make.height.equalTo(200)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        contentTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        hashtagTextField.snp.makeConstraints { make in
            make.top.equalTo(contentBackView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalTo(contentView).inset(10)
        }
        button.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(50)
        }
//        notInNetworkView.snp.makeConstraints { make in
//            make.edges.equalTo(safeAreaLayoutGuide)
//        }
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
