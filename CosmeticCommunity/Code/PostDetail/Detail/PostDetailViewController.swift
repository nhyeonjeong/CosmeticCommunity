//
//  PostDetailViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Toast
import IQKeyboardManagerSwift

final class PostDetailViewController: BaseViewController {
    var postId: String? // 받아온 post정보

    private let mainView = PostDetailView()
    private let viewModel = PostDetailViewModel()
    
    private let inputPostIdTrigger = PublishSubject<String>()
    private let inputCommentProfileButtonTrigger = PublishSubject<Int>()
    private let inputCommentDeleteTrigger = PublishSubject<Int>()
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
        print("😍\(postId)")
        inputPostIdTrigger.onNext(postId ?? "")
        setScrollViewTapGesture()
        // userdefault에 최근 본 포스트 저장
        mainView.uploadCommentView.isUserInteractionEnabled = true
    }
    override func bind() {
        let input = PostDetailViewModel.Input(inputProfileButtonTrigger: mainView.creatorView.creatorClearButton.rx.tap, inputPostIdTrigger: inputPostIdTrigger,
                                              inputClickLikeButtonTrigger: mainView.likeButton.rx.tap,
                                              inputCommentButtonTrigger: mainView.commentButton.rx.tap,
                                              inputCommentTextTrigger: mainView.commentTextView.rx.text, inputCommentProfileButtonTrigger: inputCommentProfileButtonTrigger, inputCommentDeleteTrigger: inputCommentDeleteTrigger)

        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        bindImageItems()
        bindCommentItems()
        
        output.outputProfileButtonTrigger
            .drive(with: self) { owner, profileType in
                guard let profileType else {
                    return
                }
                switch profileType {
                case .my:
                    owner.navigationController?.pushViewController(MyProfileViewController(), animated: true)
                case .other(let userId) :
                    owner.navigationController?.pushViewController(OtherProfileViewController(userId: userId), animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        output.outputPostData
            .drive(with: self) { owner, value in
                if let value {
                    owner.viewModel.postData = value // 가져온 post데이터 저장
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
        
        output.postCreatorId
            .drive(with: self) { owner, creatorId in
//                print("내가 쓴 포스트인지 확인!!")
                if creatorId == UserManager.shared.getUserId() {
                    self.configureNavigationBar()
                }
            }
            .disposed(by: viewModel.onceDisposeBag)
    }

    @objc func commentCreatorClicked(_ sender: UIButton) {
        inputCommentProfileButtonTrigger.onNext(sender.tag) // 클릭한 댓글 프로필 버튼의 tag
    }
    @objc func navigationBarButtonClicked() {
        let sheet = CustomSheetViewController()
        sheet.postData = viewModel.postData
        
        sheet.popPostDetailView = {
            self.navigationController?.popViewController(animated: true)
        }
        sheet.modalPresentationStyle = .overFullScreen
        present(sheet, animated: false)
    }
    func configureNavigationBar() {
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(navigationBarButtonClicked))
        button.tintColor = Constants.Color.point
        navigationItem.rightBarButtonItem = button
    }
}
extension PostDetailViewController {
    // 상단 이미지 그리기
    private func bindImageItems() {
        imageItems
            .bind(to: mainView.imageCollectionView.rx.items(cellIdentifier: PostImageCollectionViewCell.identifier, cellType: PostImageCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
    }
    // 댓글 테이블뷰 그리기
    private func bindCommentItems() {
        commentItems
            .bind(to: mainView.commentsTableView.rx.items(cellIdentifier: CommentTableViewCell.identifier, cellType: CommentTableViewCell.self)) {(row, element, cell) in
                cell.commentCreatorView.creatorClearButton.tag = row
                // 프로필로 이동하기
                cell.commentCreatorView.creatorClearButton.addTarget(self, action: #selector(self.commentCreatorClicked), for: .touchUpInside)
                // 내가 작성한 댓글일때만 menubutton보이기
                if element.creator.user_id == UserManager.shared.getUserId() {
                    cell.menuButton.isHidden = false
                    cell.menuButton.menu = UIMenu(children: self.configureMenuItems(row: row))
                } else {
                    cell.menuButton.isHidden = true
                }
                cell.upgradeCell(element)
                
                DispatchQueue.main.async {
                    let newHeight: CGFloat = max(1, self.mainView.commentsTableView.contentSize.height)
                    
                    self.mainView.commentsTableView.snp.updateConstraints { make in
                        make.height.equalTo(newHeight)
                    }
                }
                
            }
            .disposed(by: disposeBag)
    }
    
    func configureMenuItems(row: Int) -> [UIMenuElement] {
        let deleteAction = UIAction(title: "삭제", image: UIImage(systemName: "trash")) { _ in
            // 삭제를 누르면 테이블뷰 리로드
            self.alert(message: "댓글을 삭제합니다", defaultTitle: "삭제") {
                self.inputCommentDeleteTrigger.onNext(row)
            }
        }
        let editAction = UIAction(title: "수정", image: UIImage(systemName: "pencil")) { _ in
            //
        }
        return [deleteAction, editAction]
    }
    func setScrollViewTapGesture() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        mainView.scrollView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
