//
//  PostDetailViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import RxSwift
import RxCocoa

final class PostDetailViewController: BaseViewController {
    var postId: String? // 받아온 post정보
    
    private let mainView = PostDetailView()
    private let viewModel = PostDetailViewModel()
    
    private let inputPostIdTrigger = PublishSubject<String>()
    private let imageItems = PublishSubject<[String]>()
    private let commentItems = PublishSubject<[Comment]>()
    override func loadView() {
        view = mainView
    }
    deinit {
        print("PostDetailVC Deinit")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputPostIdTrigger.onNext(postId ?? "")
    }
    
    override func bind() {
        let input = PostDetailViewModel.Input(inputPostIdTrigger: inputPostIdTrigger, inputClickLikeButtonTrigger: mainView.likeButton.rx.tap)

        let output = viewModel.transform(input: input)
        
        bindImageItems()
        bindCommentItems()
        
        output.outputLoginView
            .drive(with: self) { owner, _ in
                owner.changeRootVC(vc: HomeViewController()) // 다시 루트뷰 바꾸기
                let vc = UINavigationController(rootViewController: NotLoginViewController())
                owner.navigationController?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.outputPostData
            .drive(with: self) { owner, value in
                if let value {
                    owner.imageItems.onNext(value.files)
//                    let likeButtonImage = owner.viewModel.isClickedLikeButton(value) ? Constants.Image.clikcedLike : Constants.Image.unclickedLike
//                    owner.mainView.likeButton.setImage(likeButtonImage, for: .normal)
                    owner.mainView.creatorView.upgradeView(value.creator)
                    owner.mainView.detailsView.upgradeView(value)
                    owner.mainView.contentLabel.text = value.content
                    owner.commentItems.onNext(value.comments)
                    
                } else {
                    owner.view.makeToast("정보불러오기에 실패했습니다", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
        
        output.outputLikeButton
            .drive(with: self) { owner, value in
                if let value {
                    let image = value ? Constants.Image.clikcedLike : Constants.Image.unclickedLike
                    owner.mainView.likeButton.setImage(image, for: .normal)
                }
            }
            .disposed(by: disposeBag)
    }
}
extension PostDetailViewController {
    private func bindImageItems() {
        imageItems
            .bind(to: mainView.imageCollectionView.rx.items(cellIdentifier: PostImageCollectionViewCell.identifier, cellType: PostImageCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
    }
    private func bindCommentItems() {
        commentItems
            .bind(to: mainView.commentsTableView.rx.items(cellIdentifier: CommentTableViewCell.identifier, cellType: CommentTableViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
    }
}
