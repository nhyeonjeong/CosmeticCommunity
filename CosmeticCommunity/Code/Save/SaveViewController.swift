//
//  SaveViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SaveViewController: BaseViewController {
    let mainView = SaveView()
    let viewModel = SaveViewModel()
    let inputRecentPosts = PublishSubject<Void>()
    let inputFetchLikedPosts = PublishSubject<Void>()
    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputFetchLikedPosts.onNext(())
    }
    
    override func bind() {
        bindCollectionView()
        let input = SaveViewModel.Input(inputFetchLikedPosts: inputFetchLikedPosts, inputRecentPosts: inputRecentPosts)
        
        let output = viewModel.transform(input: input)
        output.outputFetchLikedPosts
            .flatMap { data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
            }
            .drive(mainView.collectionVeiw.rx.items(cellIdentifier: SaveCollectionViewCell.identifier, cellType: SaveCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindCollectionView() {
        mainView.collectionVeiw.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, value in
                let vc = PostDetailViewController()
                vc.postId = value.post_id
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}
