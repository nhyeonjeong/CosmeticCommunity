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

final class UploadViewController: BaseViewController {
    
    let mainView = UploadView()
    let viewModel = UploadViewModel()

    let disposeBag = DisposeBag()
    let inputUploadButton = PublishSubject<Void>()
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

        let inputUploadTrigger = PublishSubject<Void>()
        
        let input = UploadViewModel.Input(inputTitleString: mainView.title.rx.text,
                                          inputContentString: mainView.content.rx.text,
        inputUploadButton: inputUploadButton,
        inputUploadTrigger: inputUploadTrigger)
        
        let output = viewModel.transform(input: input)

        output.outputValid
            .drive(with: self) { owner, value in
                // 다 작성했으면
                if value {
                    owner.alert(message: "업로드 하시겠습니까?") {
                        inputUploadTrigger.onNext(())
                    }
                } else {
                    owner.view.makeToast("제목과 내용을 입력해주세요", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
        
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
        
        output.outputLoginView
            .drive(with: self) { owner, _ in
                owner.changeRootVC(vc: SearchViewController()) // 다시 루트뷰 바꾸기
                let vc = UINavigationController(rootViewController: NotLoginViewController())
                owner.navigationController?.present(vc, animated: true)
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
    func setNavigationBar() {
        let button = UIBarButtonItem(title: "업로드", style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        navigationItem.rightBarButtonItem = button
    }
}


