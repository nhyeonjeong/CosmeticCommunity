//
//  PostDetailView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import SnapKit

final class PostDetailView: BaseView {
    let scrollView = {
        let view = UIScrollView()
//        view.showsVerticalScrollIndicator = false
        view.keyboardDismissMode = .onDrag
        return view
    }()
    let contentView = {
        let view = UIView()
        view.backgroundColor = .yellow
        return view
    }()
    
    lazy var imageCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: imageCollectionViewLayout())
        view.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        view.isPagingEnabled = true
        return view
    }()
    let likeButton = {
        let view = UIButton()
        view.tintColor = Constants.Color.point
        return view
    }()
    let creatorView = UserDataView(profileImageSize: .creator)
    let detailsView = PostDetailsView()
    let contentLabel = {
        let view = UILabel()
        view.backgroundColor = .yellow
        view.numberOfLines = 0
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        return view
    }()
    
    let commentsTableView = {
        let view = UITableView()
        view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        view.rowHeight = UITableView.automaticDimension
        view.backgroundColor = .lightGray
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
        contentView.addViews([imageCollectionView, likeButton, creatorView, detailsView, contentLabel, commentsTableView, bottomHiddenView])
        scrollView.addSubview(contentView)
        addViews([scrollView, uploadCommentView])
    }
    override func configureConstraints(){
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
//            make.horizontalEdges.equalTo(scrollView)
        }
        imageCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(300)
        }
        likeButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(imageCollectionView).inset(10)
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
            make.top.equalTo(detailsView.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        commentsTableView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(10)
//            make.bottom.greaterThanOrEqualTo(contentView.snp.bottom).inset(50)
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
        layout.scrollDirection = .horizontal // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
}
