//
//  SaveViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class SaveViewController: BaseViewController {
    let kignfisherManager = KingfisherManager.shared
    let mainView = SaveView()
    let viewModel = SaveViewModel()
    
    let inputProfileImageTrigger = PublishSubject<Void>()
    let inputRecentPosts = PublishSubject<Void>()
    let inputFetchLikedPosts = PublishSubject<Void>()
    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputProfileImageTrigger.onNext(())
        inputFetchLikedPosts.onNext(())
        inputRecentPosts.onNext(())
    }
    override func configureView() {
        configureNavigationBar()
    }
    override func bind() {
        bindCollectionView()
        let input = SaveViewModel.Input(inputProfileImageTrigger: inputProfileImageTrigger, inputFetchLikedPosts: inputFetchLikedPosts, inputRecentPosts: inputRecentPosts)
        
        let output = viewModel.transform(input: input)
        // 로그인화면으로 넘어가는 로직과 연결
        outputLoginView = output.outputLoginView
        outputNotInNetworkTrigger = output.outputNotInNetworkTrigger
        
        output.outputFetchLikedPosts
            .flatMap { data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
            }
            .drive(mainView.likedPostsCollection.collectionView.rx.items(cellIdentifier: SaveCollectionViewCell.identifier, cellType: SaveCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
        
        output.outputRecentPosts
            .flatMap({ data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
            })
            .drive(mainView.recentPostsCollection.collectionView.rx.items(cellIdentifier: SaveCollectionViewCell.identifier, cellType: SaveCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
            
        // 상단 프로필버튼 이미지 가져오기
        output.outputProfileImageTrigger
            .drive(with: self) { owner, path in
                KingfisherManager.shared.getImageData(path: path) { KFImage in
//                    print("vc에서 업데이트! \(KFImage)")
                    DispatchQueue.main.async {
                        owner.mainView.navigationProfilebutton.setImage(KFImage, for: .normal)
                    }
                }
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
                if let _ = value {
                    owner.mainView.notInNetworkView.isHidden = false
                } else {
                    owner.mainView.notInNetworkView.isHidden = true // 네트워크 연결되었음
                }
            }.disposed(by: disposeBag)
    }
    
    private func bindCollectionView() {
        mainView.likedPostsCollection.collectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, value in
                let vc = PostDetailViewController(postId: value.post_id)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        mainView.recentPostsCollection.collectionView.rx
            .modelSelected(PostModel.self)
            .bind(with: self) { owner, value in
                let vc = PostDetailViewController(postId: value.post_id)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func profileButtonClicked() {
        navigationController?.pushViewController(MyProfileViewController(), animated: true)
    }
}
extension SaveViewController {
    private func configureNavigationBar() {
        
        let customView = configureProfileButton(mainView.navigationProfilebutton)
        customView.addTarget(self, action: #selector(profileButtonClicked), for: .touchUpInside)
        
        let profileButton = UIBarButtonItem(customView: customView)
        navigationItem.rightBarButtonItem = profileButton
    }
}
