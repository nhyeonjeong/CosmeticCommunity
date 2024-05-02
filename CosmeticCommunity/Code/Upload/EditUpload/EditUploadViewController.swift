//
//  EditUploadViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/02.
//

import UIKit
import RxSwift
import RxCocoa

final class EditUploadViewController: UploadViewController {
    var postData: PostModel?
    let viewModel = EditUploadViewModel()
    // 수정 버튼 눌렀을 때
    private let inputEditButton = PublishSubject<Void>()
    // 사진 선택 시
    private let inputSelectPhotoItems = PublishSubject<Void>()
    // x버튼
    private let inputXbuttonTrigger = PublishSubject<Int>()
    private let inputPersonalColor = BehaviorSubject<PersonalColor>(value: .none)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.postId = postData?.post_id
        settingPostData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // personalColor다시 돌려놓기
        inputPersonalColor.onNext(.none)
    }
    override func bind() {
        bindGallery()
        let inputUploadImageTrigger = PublishSubject<Void>()
        let inputUploadTrigger = PublishSubject<Void>()
        let input = EditUploadViewModel.Input(inputTitleString: mainView.titleTextField.rx.text, inputPersonalColor: inputPersonalColor,
                                          inputContentString: mainView.contentTextView.rx.text,
                                              inputEditButton: inputEditButton, inputUploadImagesTrigger: inputUploadImageTrigger,
                                              inputEditTrigger: inputUploadTrigger, inputSelectPhotos: inputSelectPhotoItems, inputHashTags: mainView.hashtagTextField.rx.text,
                                          inputXbuttonTrigger: inputXbuttonTrigger)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        // 수정할 때
        output.outputValid
            .drive(with: self) { owner, value in
                // 다 작성했으면
                let valid = value.0
                let message = value.1
                if valid {
                    owner.alert(message: "\(message) 하시겠습니까?", defaultTitle: "\(message)") {
                        inputUploadImageTrigger.onNext(()) // 이미지 먼저 올리기..
                    }
                } else {
                    owner.view.makeToast("제목,내용,해시태그,퍼스널컬러를 입력해주세요", duration: 1.0, position: .center)
                }
            }
            .disposed(by: disposeBag)
        
        // 업로드 버튼을 눌렀을 때
        output.outputEditTrigger
            .bind(with: self) { owner, value in
                // 업로드가 성공했다면
                if let value {
                    print("업로드 성공")
                    print(value)
                    owner.navigationController?.dismiss(animated: true)
                } else {
                    owner.view.makeToast("업로드에 실패했습니다", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
        
        // 선택한 이미지 컬렉션뷰 그리기
        output.outputPhotoItems
            .drive(mainView.photoCollectionView.rx.items(cellIdentifier: UploadPhotosCollectionViewCell.identifier, cellType: UploadPhotosCollectionViewCell.self)) {(row, element, cell) in
                cell.xButton.tag = row
                cell.xButton.addTarget(self, action: #selector(self.xButtonClicked), for: .touchUpInside)
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
        
        mainView.personalSelectButton.rx.tap
            .subscribe(with: self) { owner, _ in
                let alertController = UIAlertController(title: "Title", message: "Message", preferredStyle: .actionSheet)
                
                // 네 개의 문자열로 구성된 팝업 버튼 추가
                let strings: [String] = ["Button 1", "Button 2", "Button 3", "Button 4"]
                for string in strings {
                    alertController.addAction(UIAlertAction(title: string, style: .default, handler: { action in
                        // 각 버튼 클릭 시 수행할 동작
                        print("\(string) tapped")
                    }))
                }
                
            }
            .disposed(by: disposeBag)
    }
    
    func settingPostData() {
        // 가져온 데이터가 없으면 dismiss
        guard let postData else {
            dismiss(animated: true)
            return
        }
        mainView.titleTextField.text = postData.title
        mainView.contentTextView.text = postData.content
        inputPersonalColor.onNext(postData.personalColor)
        let hashTagText = postData.hashTags.map{"#\($0)"}.joined(separator: " ")
        mainView.hashtagTextField.text = hashTagText
        configureView()
    }
    override func configureView() {
        // 가져온 데이터가 없으면 dismiss
        guard let postData else {
            dismiss(animated: true)
            return
        }
        setNavigationBar()
        mainView.personalSelectButton.menu = UIMenu(title: "퍼스널 컬러", children: {
            var components: [UIMenuElement] = []
            for item in viewModel.personalCases {
                let state: UIMenuElement.State = (item == postData.personalColor) ? .on : .off
                let action = UIAction(title: item.rawValue, state: state) { _ in
                    self.inputPersonalColor.onNext(item)
                    self.mainView.personalSelectButton.setTitle(item.rawValue, for: .normal)
                }
                components.append(action)
            }
            return components
        }())
        mainView.personalSelectButton.setTitle(postData.personalColor.rawValue, for: .normal)
        mainView.personalSelectButton.showsMenuAsPrimaryAction = true

    }
    // 업로드 버튼
    @objc override func rightBarButtonItemClicked() {
        inputEditButton.onNext(())
    }
    override func setNavigationBar() {
        let uploadButton = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        
        let popButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(popButtonClicked))
        navigationItem.rightBarButtonItem = uploadButton
        navigationItem.leftBarButtonItem = popButton
    }
}

