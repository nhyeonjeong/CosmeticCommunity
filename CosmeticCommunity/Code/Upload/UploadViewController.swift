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

final class UploadViewController: BaseViewController {
    
    private let mainView = UploadView()
    private let viewModel = UploadViewModel()

    // 업로드 버튼 눌렀을 때
    private let inputUploadButton = PublishSubject<Void>()
    // 사진 선택 시
    private let inputSelectPhotoItems = PublishSubject<Void>()
    // x버튼
    private let inputXbuttonTrigger = PublishSubject<Int>()
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
        Observable.just(viewModel.personalColors)
            .bind(to: mainView.personalColorPicker.rx.itemTitles) { row, item in

                return item.rawValue
            }
            .disposed(by: disposeBag)
        bindGallery() // 사진첩 열기 rx 연결
        let inputUploadImageTrigger = PublishSubject<Void>()
        let inputUploadTrigger = PublishSubject<Void>()
        let input = UploadViewModel.Input(inputTitleString: mainView.titleTextField.rx.text,
                                          inputPersonalPicker: mainView.personalColorPicker.rx.itemSelected,
                                          inputContentString: mainView.contentTextView.rx.text,
                                          inputUploadButton: inputUploadButton, inputUploadImagesTrigger: inputUploadImageTrigger,
                                          inputUploadTrigger: inputUploadTrigger, inputSelectPhotos: inputSelectPhotoItems, inputHashTags: mainView.hashtagTextField.rx.text,
                                          inputXbuttonTrigger: inputXbuttonTrigger)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        output.outputValid
            .drive(with: self) { owner, value in
                // 다 작성했으면
                if value {
                    owner.alert(message: "업로드 하시겠습니까?", defaultTitle: "업로드") {
                        inputUploadImageTrigger.onNext(()) // 이미지 먼저 올리기..
                    }
                } else {
                    owner.view.makeToast("제목과 내용을 입력해주세요", duration: 1.0, position: .center)
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
    }
    override func configureView() {
        setNavigationBar()
//        configurePickerView()
    }
    @objc func xButtonClicked(_ sender: UIButton) {
        inputXbuttonTrigger.onNext(sender.tag)
    }
    // 업로드 버튼
    @objc func rightBarButtonItemClicked() {
        inputUploadButton.onNext(())
    }
    @objc func popButtonClicked() {
        navigationController?.dismiss(animated: true)
    }
}

extension UploadViewController {
    private func setNavigationBar() {
        let uploadButton = UIBarButtonItem(title: "업로드", style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        
        let popButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(popButtonClicked))
        navigationItem.rightBarButtonItem = uploadButton
        navigationItem.leftBarButtonItem = popButton
    }
    
    private func bindGallery() {
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

//extension UploadViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return viewModel.personalColors.count
//    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return viewModel.personalColors[row].rawValue
//    }
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 40
//    }
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        let title = viewModel.personalColors[row]
//        let attributes: [NSAttributedString.Key: Any] = [
//            .foregroundColor: title.backgroundColor,
//            .font: UIFont.systemFont(ofSize: 2)
//            
//        ]
//        return NSAttributedString(string: title.rawValue, attributes: attributes)
//    }
//    
//    func configurePickerView() {
//        mainView.personalColorPicker.delegate = self
//        mainView.personalColorPicker.dataSource = self
//    }
//}
