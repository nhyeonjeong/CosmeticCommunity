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
import PhotosUI

final class UploadViewController: BaseViewController {
    
    private let mainView = UploadView()
    private let viewModel = UploadViewModel()

    // 업로드 버튼 눌렀을 때
    private let inputUploadButton = PublishSubject<Void>()
    // 사진 선택 시
    private let inputSelectPhotoItems = PublishSubject<Void>()
    
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
        
        bindGallery() // 사진첩 열기 rx 연결
        let inputUploadImageTrigger = PublishSubject<Void>()
        let inputUploadTrigger = PublishSubject<Void>()
        let input = UploadViewModel.Input(inputTitleString: mainView.title.rx.text,
                                          inputContentString: mainView.content.rx.text,
                                          inputUploadButton: inputUploadButton, inputUploadImagesTrigger: inputUploadImageTrigger,
                                          inputUploadTrigger: inputUploadTrigger, inputSelectPhotos: inputSelectPhotoItems)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        output.outputValid
            .drive(with: self) { owner, value in
                // 다 작성했으면
                if value {
                    owner.alert(message: "업로드 하시겠습니까?") {
                        inputUploadImageTrigger.onNext(()) // 이미지 먼저 올리기..
                    }
                } else {
                    owner.view.makeToast("제목과 내용을 입력해주세요", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
        // 업로드 버튼을 눌렀을 때
        output.outputUploadTrigger
            .bind(with: self) { owner, value in
                // 업로드가 성공했다면
                if let _ = value {
                    print("업로드 성공")
                    owner.navigationController?.popViewController(animated: true)
                } else {
                    owner.view.makeToast("업로드에 실패했습니다", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
        // 선택한 이미지 컬렉션뷰 그리기
        output.outputPhotoItems
            .drive(mainView.photoCollectionView.rx.items(cellIdentifier: UploadPhotosCollectionViewCell.identifier, cellType: UploadPhotosCollectionViewCell.self)) {(row, element, cell) in
                
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
    }

    override func configureView() {
        setNavigationBar()
    }
    // 업로드 버튼
    @objc func rightBarButtonItemClicked() {
        inputUploadButton.onNext(())
    }
}

extension UploadViewController {
    private func setNavigationBar() {
        let button = UIBarButtonItem(title: "업로드", style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        navigationItem.rightBarButtonItem = button
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
