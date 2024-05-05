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
//        inputTagSelectedTrigger.onNext(0)
    }
    override func bind() {
        let input = HomeViewModel.Input(inputProfileImageTrigger: inputProfileImageTrigger, inputMostLikedPostsTrigger: inputMostLikedPostsTrigger, inputTagSelectedTrigger: inputTagSelectedTrigger)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView // 로그인화면으로 넘기는 로직연결

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
            .debug()
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
                print("💎")
                print(element)
                cell.upgradeCell(element)
                cell.collectionView.rx.modelSelected(PostModel.self)
                    .bind(with: self) { owner, post in
                        print("🩷")
                        let vc = PostDetailViewController()
                        vc.postId = post.post_id
                        owner.navigationController?.pushViewController(vc, animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        mainView.mostLikedCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, post in
                let vc = PostDetailViewController()
                vc.postId = post.post_id
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        mainView.tagCollectionView.rx.itemSelected
            .debug()
            .bind(with: self) { owner, indexPath in
                print("📆\(indexPath)")
                owner.inputTagSelectedTrigger.onNext(indexPath.row)
                
            }
            .disposed(by: disposeBag)
        
        mainView.tagPostCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, post in
                print("🩷")
                let vc = PostDetailViewController()
                vc.postId = post.post_id
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    
    }
    override func configureView() {
        configureNavigationBar()
    }
    @objc func profileButtonClicked() {
        navigationController?.pushViewController(MyProfileViewController(), animated: true)
    }
    @objc func searchButtonClicked() {
        navigationController?.pushViewController(SearchHomeViewController(), animated: true)
    }
}

extension HomeViewController {
    func configureNavigationBar() {
        navigationItem.title = "CoCo"
        let customView = configureProfileButton(mainView.navigationProfilebutton)
        customView.addTarget(self, action: #selector(profileButtonClicked), for: .touchUpInside)
        
        let profileButton = UIBarButtonItem(customView: customView)
        
        let searchButton = UIBarButtonItem(image: Constants.Image.category                                         , style: .plain, target: self, action: #selector(searchButtonClicked))
        
        navigationItem.rightBarButtonItems = [profileButton, searchButton]
    }
}
