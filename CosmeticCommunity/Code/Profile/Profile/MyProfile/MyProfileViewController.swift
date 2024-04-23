//
//  ProfileViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import RxSwift
import RxCocoa

final class MyProfileViewController: BaseViewController {
    private let mainView = MyProfileView()
    private let viewModel = MyProfileViewModel()
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
        let input = MyProfileViewModel.Input(inputFetchProfile: inputFetchProfile)
//        let countCollectionViewItems = PublishSubject<[FollowCounts]>() // 팔로우관련 숫자 리로드
    //        let postsCollectionViewItems = // 작성한 포스트 다시 리로드
        let output = viewModel.transform(input: input)
        
        output.outputProfileResult
            .drive(with: self) { owner, data in
                if let data {
                    owner.mainView.upgradeUserView(data) // 상단 뷰 다시 그리기
                } else {
                    owner.view.makeToast("통신에 실패했습니다", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
    
        output.outputPostItems
            .flatMap({ data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
                
            })
            .drive(mainView.postsCollectionView.rx.items(cellIdentifier: PostImageCollectionViewCell.identifier, cellType: PostImageCollectionViewCell.self)) { (row, element, cell) in
                cell.upgradeCell(element.files.first)
                print("\(element)")
            }
            .disposed(by: disposeBag)
            
    }
    
}
extension MyProfileViewController {
    func configureNavigationBar() {
        navigationItem.title = "프로필"
    }
}
