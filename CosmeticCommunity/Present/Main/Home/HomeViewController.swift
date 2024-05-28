//
//  SearchViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeViewController: BaseViewController {

    let mainView = HomeView()
    let viewModel = HomeViewModel()
    // viewModel에 전달할 트리거
    let inputProfileImageTrigger = PublishSubject<Void>()
    let inputMostLikedPostsTrigger = PublishSubject<Void>()
    let inputTagSelectedTrigger = PublishSubject<Int>()
    override func loadView() {
        view = mainView
    }
    deinit {
        print("HomeVC Deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputProfileImageTrigger.onNext(())
        inputMostLikedPostsTrigger.onNext(())
    }
    override func bind() {
        usedItemButtonClicked()
        
//        inputTagSelectedTrigger.onNext(viewModel.selectedTagRow)//여기에 해야 indexrange 오류가 안 난다..?
        let input = HomeViewModel.Input(inputProfileImageTrigger: inputProfileImageTrigger, inputMostLikedPostsTrigger: inputMostLikedPostsTrigger, inputTagSelectedTrigger: inputTagSelectedTrigger)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView // 로그인화면으로 넘기는 로직연결
        outputNotInNetworkTrigger = output.outputNotInNetworkTrigger
        // 상단 프로필버튼 이미지 가져오기
        output.outputProfileImageTrigger
            .drive(with: self) { owner, path in
                KingfisherManager.shared.getImageData(path: path) { KFImage in
                    print("vc에서 업데이트! \(KFImage)")
                    DispatchQueue.main.async {
                        owner.mainView.navigationProfilebutton.setImage(KFImage, for: .normal)
                    }
                }
            }
            .disposed(by: disposeBag)
        output.outputMostLikedPostsItem
            .drive(mainView.mostLikedCollectionView.rx.items(cellIdentifier: HomePostLargeCollectionViewCell.identifier, cellType: HomePostLargeCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
        output.outputTagItems
            .debug()
            .drive(mainView.tagCollectionView.rx.items(cellIdentifier: HomeTagCollectionViewCell.identifier, cellType: HomeTagCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element, isSelected: row == self.viewModel.selectedTagRow)
            }
            .disposed(by: disposeBag)
        output.outputTagPostsItem
            .drive(mainView.tagPostCollectionView.rx.items(cellIdentifier: TagPostCollectionViewCell.identifier, cellType: TagPostCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
                cell.collectionView.rx.modelSelected(PostModel.self)
                    .bind(with: self) { owner, post in
                        let vc = PostDetailViewController(postId: post.post_id)
                        owner.navigationController?.pushViewController(vc, animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        mainView.mostLikedCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, post in
                let vc = PostDetailViewController(postId: post.post_id)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        mainView.tagCollectionView.rx.itemSelected
            .debug()
            .bind(with: self) { owner, indexPath in
                owner.inputTagSelectedTrigger.onNext(indexPath.row)
                
            }
            .disposed(by: disposeBag)
        
        mainView.tagPostCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, post in
                let vc = PostDetailViewController(postId: post.post_id)
                owner.navigationController?.pushViewController(vc, animated: true)
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
    override func configureView() {
        configureNavigationBar()
    }
    @objc func profileButtonClicked() {
        navigationController?.pushViewController(MyProfileViewController(), animated: true)
    }
    @objc func searchButtonClicked() {
        navigationController?.pushViewController(SearchViewController(postType: .home), animated: true)
    }
    func usedItemButtonClicked() {
        mainView.usedItemButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(SearchViewController(postType: .usedItem), animated: true)
            }.disposed(by: disposeBag)
    }
}
extension HomeViewController {
    func configureNavigationBar() {
        navigationItem.title = "CoCo"
        let customView = configureProfileButton(mainView.navigationProfilebutton)
        customView.addTarget(self, action: #selector(profileButtonClicked), for: .touchUpInside)
        
        let profileButton = UIBarButtonItem(customView: customView)
        
        let searchButton = UIBarButtonItem(image: Constants.Image.searchButton                                         , style: .plain, target: self, action: #selector(searchButtonClicked))
        searchButton.tintColor = Constants.Color.point
        navigationItem.rightBarButtonItems = [profileButton, searchButton]
    }
}
