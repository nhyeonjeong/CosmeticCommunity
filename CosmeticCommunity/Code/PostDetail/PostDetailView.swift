//
//  PostDetailView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import SnapKit

final class PostDetailView: BaseView {
    let scrollView = UIScrollView()
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
    
//    lazy var commentsCollectoinView = UICollectionView(frame: .zero, collectionViewLayout: commentsCollectionViewLayout())
    let commentsTableView = {
        let view = UITableView()
        view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        view.rowHeight = UITableView.automaticDimension
        return view
    }()
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
        addViews([imageCollectionView, likeButton, creatorView, detailsView, contentLabel, commentsTableView, uploadCommentView])
    }
    override func configureConstraints(){
        
        imageCollectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
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
            make.horizontalEdges.equalToSuperview().inset(10)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
        uploadCommentView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(safeAreaLayoutGuide)
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
    override func configureView() {
        detailsView.backgroundColor = .systemGreen
        commentsTableView.backgroundColor = .separator
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
    /*
    func commentsCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 160) // 없으면 안됨
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        layout.scrollDirection = .horizontal // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
     */
}
