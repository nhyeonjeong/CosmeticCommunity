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
    private let inputPrepatchTrigger = PublishSubject<[IndexPath]>()
    override func loadView() {
        view = mainView
    }
            
    deinit {
        print("MyProfileVC Deinit")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.limit = "\(max(viewModel.postData.count, 20))"
        inputFetchProfile.onNext(())
    }
    override func bind() {
        let input = MyProfileViewModel.Input(inputFetchProfile: inputFetchProfile, inputPrepatchTrigger: inputPrepatchTrigger)
        let output = viewModel.transform(input: input)
        
        outputLoginView = output.outputLoginView
        outputNotInNetworkTrigger = output.outputNotInNetworkTrigger
        
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

        mainView.postsCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, data in
                let vc = PostDetailViewController(postId: data.post_id)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        // prefetch
        mainView.postsCollectionView.rx.prefetchItems
            .bind(with: self) { owner, indexPaths in
                owner.inputPrepatchTrigger.onNext(indexPaths)
            }
            .disposed(by: disposeBag)
        
        output.outputNoResult
            .drive(with: self) { owner, value in
                owner.mainView.noResultLabel.isHidden = value
            }
            .disposed(by: disposeBag)
        
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
        configureNavigationBar()
    }
    
}
extension MyProfileViewController {
    func configureNavigationBar() {
        navigationItem.title = "내 프로필"
    }
}
