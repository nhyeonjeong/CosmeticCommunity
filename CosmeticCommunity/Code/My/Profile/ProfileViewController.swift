//
//  ProfileViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileViewController: BaseViewController {
    private let mainView = ProfileView()
    private let viewModel = ProfileViewModel()
    private let inputFetchProfile = PublishSubject<Void>()
    override func loadView() {
        view = mainView
    }
            
    deinit {
        print("ProfileVC Deinit")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputFetchProfile.onNext(())
    }
    override func bind() {
        let input = ProfileViewModel.Input(inputFetchProfile: inputFetchProfile)
        let output = viewModel.transform(input: input)
        output.outputProfileResult
            .drive(with: self) { owner, data in
                if let data {
                    owner.mainView.upgradeView(data)
                } else {
                    owner.view.makeToast("통신에 실패했습니다", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
    }
}
extension ProfileViewController {
    func configureNavigationBar() {
        navigationItem.title = "프로필"
    }
}
