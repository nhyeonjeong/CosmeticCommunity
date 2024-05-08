//
//  UploadViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import RxSwift
import RxCocoa
import Toast
import PhotosUI // 갤러리

class UploadViewController: BaseViewController {
    
    let mainView = UploadView()
    private let viewModel = UploadViewModel()

    // 업로드 버튼 눌렀을 때
    private let inputUploadButton = PublishSubject<Void>()
    // 사진 선택 시
    private let inputSelectPhotoItems = PublishSubject<Void>()
    // x버튼
    private let inputXbuttonTrigger = PublishSubject<Int>()
    private let inputPersonalColor = BehaviorSubject<PersonalColor>(value: .none)
    private let contentTextIsEditing = BehaviorSubject<Bool>(value: false)
    override func loadView() {
        view = mainView
    }
    deinit {
        print("UploadVC Deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 로그아웃된 상태라면 유저디폴트에 userId가 없다.
        let userId = UserDefaults.standard.string(forKey: "userId")
        // 로그아웃된 상태라면 로그인해달라는 화면
        guard let _ = userId else {
            let vc = UINavigationController(rootViewController: NotLoginViewController())
            vc.modalPresentationStyle = .fullScreen
            navigationController?.present(vc, animated: true)
            return
        }
        
    }
    override func bind() {
        print("Upload")
        bindGallery() // 사진첩 열기 rx 연결
        let inputUploadImageTrigger = PublishSubject<Void>()
        let inputUploadTrigger = PublishSubject<Void>()
        let input = UploadViewModel.Input(inputTitleString: mainView.titleTextField.textField.rx.text, inputPersonalColor: inputPersonalColor,
                                          inputContentString: mainView.contentTextView.rx.text,
                                          inputUploadButton: inputUploadButton, inputUploadImagesTrigger: inputUploadImageTrigger,
                                          inputUploadTrigger: inputUploadTrigger, inputSelectPhotos: inputSelectPhotoItems, inputHashTags: mainView.hashtagTextField.textField.rx.text,
                                          inputXbuttonTrigger: inputXbuttonTrigger)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        outputNotInNetworkTrigger = output.outputNotInNetworkTrigger
        
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
                    owner.view.makeToast("모든 항목을 작성해주세요", duration: 1.0, position: .bottom)
                }
            }
            .disposed(by: disposeBag)
        
        // 업로드 버튼을 눌렀을 때
        output.outputUploadTrigger
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
    
        // MARK: - contentTextView placeholder
        contentTextIsEditing
            .bind(with: self) { owner, isEditing in
                if !isEditing { // 작성중이 아니라면
                    owner.mainView.contentTextView.text = "상품에 대한 설명을 입력해주세요"
                    owner.mainView.contentTextView.textColor = Constants.Color.subText
                } else {
                    owner.mainView.contentTextView.textColor = Constants.Color.text
                }
            }.disposed(by: disposeBag)
        
        mainView.contentTextView.rx.didEndEditing
            .withLatestFrom(contentTextIsEditing)
            .debug()
            .bind(with: self) { owner, isEditing in
                if owner.mainView.contentTextView.text == "" {
                    owner.contentTextIsEditing.onNext(false)
                }
                print("😎change")
            }.disposed(by: disposeBag)
        
        mainView.contentTextView.rx.didBeginEditing
            .withLatestFrom(contentTextIsEditing)
            .bind(with: self) { owner, isEditing in
                if !isEditing {
                    owner.mainView.contentTextView.text = ""
                    owner.contentTextIsEditing.onNext(true)
                }
            }.disposed(by: disposeBag)
        
        mainView.button.rx.tap
            .bind(with: self) { owner, _ in
                owner.inputUploadButton.onNext(())
            }.disposed(by: disposeBag)
        
        // MARK: - Network
        // 새로고침 버튼 tap
        mainView.notInNetworkView.restartButton.rx.tap
            .withLatestFrom(viewModel.outputNotInNetworkTrigger)
            .debug()
            .bind(with: self) { owner, againFunc in
                againFunc?()
            }.disposed(by: disposeBag)
        
        outputNotInNetworkTrigger
            .asDriver(onErrorJustReturn: {})
            .drive(with: self) { owner, value in
                if let value {
                    owner.mainView.notInNetworkView.isHidden = false
                } else {
                    owner.mainView.notInNetworkView.isHidden = true // 네트워크 연결되었음
                }
            }.disposed(by: disposeBag)

    }
    override func configureView() {
        setNavigationBar()
        
        mainView.button.configureTitle("업로드")
        
        mainView.personalSelectButton.menu = UIMenu(title: "퍼스널 컬러", children: [
            UIAction(title: "봄웜", state: .off, handler: { _ in
                self.inputPersonalColor.onNext(.spring)
                self.mainView.personalSelectButton.setTitle("봄웜", for: .normal)
                self.setSelectedPersonalButtonImage()
            }),
            UIAction(title: "여름쿨", state: .off, handler: { _ in
                self.inputPersonalColor.onNext(.summer)
                self.mainView.personalSelectButton.setTitle("여름쿨", for: .normal)
                self.setSelectedPersonalButtonImage()
            }),
            UIAction(title: "가을웜", state: .off, handler: { _ in
                self.inputPersonalColor.onNext(.fall)
                self.mainView.personalSelectButton.setTitle("가을웜", for: .normal)
                self.setSelectedPersonalButtonImage()
            }),
            UIAction(title: "겨울쿨", handler: { _ in
                self.inputPersonalColor.onNext(.winter)
                self.mainView.personalSelectButton.setTitle("겨울쿨", for: .normal)
                self.setSelectedPersonalButtonImage()
            })])
        
        mainView.personalSelectButton.showsMenuAsPrimaryAction = true
    }
    @objc func xButtonClicked(_ sender: UIButton) {
        inputXbuttonTrigger.onNext(sender.tag)
    }

    @objc func popButtonClicked() {
        navigationController?.dismiss(animated: true)
    }
    func setNavigationBar() {
        navigationItem.title = "상품 등록"
        let popButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(popButtonClicked))
        popButton.tintColor = Constants.Color.point
        navigationItem.leftBarButtonItem = popButton
    }
}

extension UploadViewController {
    func setSelectedPersonalButtonImage() {
        mainView.personalSelectButton.configuration?.title = "봄웜"
        mainView.personalSelectButton.configuration?.image = Constants.Image.checkedItem
    }
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

extension UploadViewController: PHPickerViewControllerDelegate {
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
