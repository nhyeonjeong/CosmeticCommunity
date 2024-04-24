//
//  PostDetailViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class PostDetailViewController: BaseViewController {
    var postId: String? // 받아온 post정보
    
    private let mainView = PostDetailView()
    private let viewModel = PostDetailViewModel()
    
    private let inputPostIdTrigger = PublishSubject<String>()
    private let imageItems = PublishSubject<[String]>()
    private let commentItems = PublishSubject<[CommentModel]>()
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
        let input = PostDetailViewModel.Input(inputProfileButtonTrigger: mainView.creatorClearButton.rx.tap, inputPostIdTrigger: inputPostIdTrigger,
                                              inputClickLikeButtonTrigger: mainView.likeButton.rx.tap,
                                              inputCommentButtonTrigger: mainView.commentButton.rx.tap,
                                              inputCommentTextTrigger: mainView.commentTextView.rx.text)

        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        bindImageItems()
        bindCommentItems()
        
        output.outputProfileButtonTrigger
            .drive(with: self) { owner, profileType in
                guard let profileType else {
                    return
                }
                let vc = profileType == .my ? MyProfileViewController() : OtherProfileViewController()
                
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.outputPostData
            .drive(with: self) { owner, value in
                if let value {
                    owner.imageItems.onNext(value.files)
                    owner.mainView.creatorView.upgradeView(profileImage: value.creator.profileImage, nick: value.creator.nick)
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
                    let image = owner.viewModel.isClickedLikeButton(value) ? Constants.Image.clickedLike : Constants.Image.unclickedLike
                    owner.mainView.likeButton.setImage(image, for: .normal) // 추천 버튼 실기간 변경
                    owner.mainView.detailsView.upgradeLikeCountLabel(value.likes.count)
                }
            }
            .disposed(by: disposeBag)
        
        output.outputNotValid
            .drive(with: self) { owner, _ in
                owner.view?.makeToast("댓글을 입력해주세요", duration: 1.0, position: .center)
            }
            .disposed(by: disposeBag)
        
        output.outputAlert
            .drive(with: self) { owner, text in
                owner.view.makeToast(text, duration: 1.0, position: .center)
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
