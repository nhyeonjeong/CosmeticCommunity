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

final class PostDetailViewController: BaseViewController {
    let postId: String // 받아온 post정보
    init(postId: String) {
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
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
        print(#function, "🐰")
        super.viewWillAppear(true)
        print("😍\(postId)")
        inputPostIdTrigger.onNext(postId)
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
        outputNotInNetworkTrigger = output.outputNotInNetworkTrigger
        
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
                    owner.mainView.creatTimeLabel.text = value.createdAt.getDateFromISO8601()
                    var hashtagText = ""
                    _ = value.hashTags.map({ hashtag in
                        hashtagText += "#\(hashtag)"
                    })
                    owner.mainView.hashTagLabel.text = hashtagText
                    owner.commentItems.onNext(value.comments)
                    owner.mainView.commentTextView.text = ""
                } else {
                    owner.view.makeToast("정보불러오기에 실패했습니다", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
        
        // 추천
        output.outputLikeButton
            .drive(with: self) { owner, value in
                if let value {
                    let isClicked = owner.viewModel.isClickedLikeButton(value)
                    let image = isClicked ? Constants.Image.clickedLike : Constants.Image.unclickedLike
                    owner.mainView.likeButton.setImage(image, for: .normal) // 추천 버튼 실기간 변경
                    owner.mainView.detailsView.upgradeLikeAndCommentsCountLabel(value)
                }
            }
            .disposed(by: disposeBag)
        
        output.outputLottieAnimation
            .drive(with: self) { owner, value in
                if value {
                    owner.mainView.likeLottie.loopMode = .playOnce
                    owner.mainView.likeLottie.animationSpeed = 1
                    owner.mainView.likeLottie.play()
                    owner.mainView.likeLottie.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // Hide the Lottie view
                        owner.mainView.likeLottie.isHidden = true
                    }
                } else {
                    owner.mainView.likeLottie.isHidden = true
                }
            }.disposed(by: disposeBag)
        
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
                if creatorId == UserManager.shared.getUserId() {
                    self.configureNavigationBar()
                }
            }
            .disposed(by: viewModel.onceDisposeBag)
        
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
        
        // MARK: - 결제버튼
        mainView.paymentButton.rx.tap
            .bind(with: self) { owner, _ in
                guard let postData = owner.viewModel.postData else {
                    owner.view.makeToast("게시글 정보를 불러오지 못했습니다", duration: 1.0, position: .top)
                    return
                }
                owner.navigationController?.pushViewController(PaymentViewController(postData: postData), animated: true)
            }.disposed(by: disposeBag)
    }

    @objc func commentCreatorClicked(_ sender: UIButton) {
        inputCommentProfileButtonTrigger.onNext(sender.tag) // 클릭한 댓글 프로필 버튼의 tag
    }
    @objc func navigationBarButtonClicked() {
        let sheet = CustomSheetViewController()
        sheet.postData = viewModel.postData
        sheet.popAfterEditPost = {
            self.inputPostIdTrigger.onNext(self.postId) // 수정후에는 다시 패치
        }
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
        mainView.imageCollectionView.rx.willDisplayCell
            .map { $0.at }
            .subscribe(with: self) { owner, indexPath in
                if let post = self.viewModel.postData {
                    owner.mainView.imageCounterLabel.text = " \(indexPath.row + 1) / \(post.files.count) "
                }
            }.disposed(by: disposeBag)
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
                // 댓글테이블뷰 높이 다시 잡기
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
}
