//
//  PostDetailView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import SnapKit
import Lottie

final class PostDetailView: BaseView {
    let likeLottie = {
        let view: LottieAnimationView = .init(name: "thumbsup")
        view.contentMode = .scaleAspectFit
        view.isHidden = true // 처음에는 숨겨짐
        return view
    }()
    let scrollView = {
        let view = UIScrollView()
//        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .onDrag
        return view
    }()
    let contentView = UIView()
    let imageCounterLabel = {
        let view = UILabel()
        view.backgroundColor = Constants.Color.subText.withAlphaComponent(0.5)
        view.clipsToBounds = true
        return view
    }()
    lazy var imageCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionViewLayout())
        view.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        view.bounces = false
        view.isPagingEnabled = true
        return view
    }()
    let likeButton = {
        let view = UIButton()
        var config = UIButton.Configuration.plain()
        config.buttonSize = .large
        view.configuration = config
        view.tintColor = Constants.Color.point
        view.backgroundColor = .clear
        return view
    }()
    let creatorView = UserDataView(.creator)
    let detailsView = PostDetailsView()
    let contentLabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        return view
    }()
    
    let commentsTableView = {
        let view = UITableView()
        view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        view.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .white
        view.isScrollEnabled = false
        return view
    }()
    let bottomHiddenView = UIView()
    let uploadCommentView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.point.withAlphaComponent(0.3)
        return view
    }()
    let commentTextView = {
        let view = UITextView()
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1
        view.font = Constants.Font.normal
        return view
    }()
    let commentButton = {
        let view = UIButton()
        view.setTitle(" 댓글쓰기 ", for: .normal)
        view.setTitleColor(Constants.Color.point, for: .normal)
        view.backgroundColor = .white
        return view
    }()
    override func configureHierarchy() {
        uploadCommentView.addViews([commentTextView, commentButton])
        contentView.addViews([imageCollectionView, imageCounterLabel, likeButton, creatorView, detailsView, contentLabel, commentsTableView, bottomHiddenView])
        scrollView.addSubview(contentView)
        addViews([scrollView, uploadCommentView, likeLottie])
    }
    override func configureConstraints(){
        likeLottie.snp.makeConstraints { make in
            make.center.equalTo(safeAreaLayoutGuide)
            make.size.equalTo(200)
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(300)
        }
        imageCounterLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageCollectionView).inset(20)
            make.centerY.equalTo(likeButton)
        }
        likeButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(imageCollectionView)
            make.size.equalTo(60)
        }
        creatorView.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        detailsView.snp.makeConstraints { make in
            make.top.equalTo(creatorView.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.height.equalTo(100)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(detailsView.personalColorLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        commentsTableView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(10)
            make.height.equalTo(1)
        }
        bottomHiddenView.snp.makeConstraints { make in
            make.top.equalTo(commentsTableView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(contentView)
            make.height.equalTo(50)
        }
        uploadCommentView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide)
            make.bottom.equalTo(self.keyboardLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        commentTextView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
        }
        commentButton.snp.makeConstraints { make in
            make.leading.equalTo(commentTextView.snp.trailing).offset(8)
            make.bottom.equalToSuperview().inset(5)
            make.trailing.equalToSuperview().inset(10)
//            make.height.equalTo(30)
        }
    }
}
extension PostDetailView {
    func imageCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 300) // 없으면 안됨
        layout.minimumLineSpacing = 0 // 세로간
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        return layout
    }
}
