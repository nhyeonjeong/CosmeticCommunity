//
//  EditUploadViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/02.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class EditUploadViewController: BaseViewController {
    var postData: PostModel?
    var popEditSheet: (() -> Void)?
    var popAfterEditPost: (() -> Void)?
    
    let viewModel = EditUploadViewModel()
    let mainView = UploadView()
    override func loadView() {
        view = mainView
    }
    // 수정 버튼 눌렀을 때
    private let inputEditButton = PublishSubject<Void>()
    // 사진 선택 시
    private let inputSelectPhotoItems = PublishSubject<Void>()
    // x버튼
    private let inputXbuttonTrigger = PublishSubject<Int>()
    private let inputPersonalColor = BehaviorSubject<PersonalColor>(value: .none)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        viewModel.postId = postData?.post_id
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // personalColor다시 돌려놓기
//        inputPersonalColor.onNext(.none)
    }
    override func bind() {
        print("Edit")
        bindGallery()
        let inputUploadImageTrigger = PublishSubject<Void>()
        let inputUploadTrigger = PublishSubject<Void>()
        let input = EditUploadViewModel.Input(inputTitleString: mainView.titleTextField.textField.rx.text, inputPersonalColor: inputPersonalColor,
                                          inputContentString: mainView.contentTextView.rx.text,
                                              inputEditButton: inputEditButton, inputUploadImagesTrigger: inputUploadImageTrigger,
                                              inputEditTrigger: inputUploadTrigger, inputSelectPhotos: inputSelectPhotoItems, inputHashTags: mainView.hashtagTextField.textField.rx.text,
                                          inputXbuttonTrigger: inputXbuttonTrigger)
        settingPostData() // 여기 있어야 하는 이유?
        
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
                    owner.navigationController?.dismiss(animated: true)
                    owner.popAfterEditPost?()
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
    func settingPostData() {
        // 가져온 데이터가 없으면 dismiss
        guard let postData else {
            dismiss(animated: true)
            return
        }
        
        print("postData.title: \(postData.title)")
        mainView.titleTextField.textField.text = postData.title
        mainView.contentTextView.text = postData.content
//        mainView.titleTextField.text = postData.title

        inputPersonalColor.onNext(postData.personalColor)
        let hashTagText = postData.hashTags.map{"#\($0)"}.joined(separator: " ")
        mainView.hashtagTextField.textField.text = hashTagText
//        configureView()
    }
    // 업로드 버튼
    @objc func rightBarButtonItemClicked() {
        inputEditButton.onNext(())
    }
    @objc func xButtonClicked(_ sender: UIButton) {
        inputXbuttonTrigger.onNext(sender.tag)
    }
    @objc func popButtonClicked() {
        dismiss(animated: true)
        popEditSheet?() // dismiss하면서 다시 포스트 조회하도록
    }
    func setNavigationBar() {
        let uploadButton = UIBarButtonItem(title: "수정", style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        
        let popButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(popButtonClicked))
        navigationItem.rightBarButtonItem = uploadButton
        navigationItem.leftBarButtonItem = popButton
    }
}

extension EditUploadViewController {
    func bindGallery() {
        // 사진첩 열기
        mainView.addPhotoButton.rx.tap
            .bind(with: self) { owner, _ in
                
                var configuration = PHPickerConfiguration()
                
                // 배열형태로 여러 형태의 미디어를 가져올 수 있다. .any(of: [])
                // 하나만 있으면 .images
                configuration.filter = .any(of: [.videos, .images]) // imagePicker띄울 때 비디오만 가지고 올 지, 사진만 가지고 올 지 선택 -> video / livePhotos ```
                
                configuration.selectionLimit = 5 // 여러 장 선택 가능(최대 2장 선택/0은 무제한선택)
                let picker = PHPickerViewController(configuration: configuration) // init()는 PHPicker에 없으므로 configurationt설정 필요(button에 이 설정이 있는 것처럼 configuration과 관련된 속성 설정이 필요하다)
                picker.delegate = owner // 부가적인 기능은 프로토콜안에 내장되어있다
                owner.present(picker, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
extension EditUploadViewController: PHPickerViewControllerDelegate {
    // 사진을 선택했을 대 Add눌렀을 때?
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
//        print("1")
        let group = DispatchGroup()
        
        for image in results {
            group.enter()
//            print("2")
            let itemProvider = image.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
//                print("2-1")
                itemProvider.loadObject(ofClass: UIImage.self) { item, error in
//                    print("2-2")
                    self.viewModel.appendPhotos(item)
//                    print(self.viewModel.photos)
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) {
//            print("3")
            self.inputSelectPhotoItems.onNext(())
        }
    }
}
