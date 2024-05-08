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
    let notInNetworkView = {
        let view = NotInNetworkView()
        view.isHidden = true
        return view
    }()
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
    let hashTagLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.normal)
        view.numberOfLines = 0
        return view
    }()
    let creatTimeLabel = {
        let view = UILabel()
        view.configureLabel(textColor: Constants.Color.subText, font: Constants.Font.small)
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
        view.layer.cornerRadius = 10
        view.backgroundColor = Constants.Color.secondPoint
        return view
    }()
    let commentTextView = {
        let view = UITextView()
        view.layer.cornerRadius = 10
        view.backgroundColor = Constants.Color.secondPoint.withAlphaComponent(0.3)
        view.font = Constants.Font.normal
        return view
    }()
    let commentButton = {
        let view = UIButton()
        var config = UIButton.Configuration.filled()
        config.buttonSize = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        view.setImage(UIImage(systemName: "arrowshape.turn.up.backward.fill"), for: .normal)
        view.setTitleColor(Constants.Color.text, for: .normal)
        view.backgroundColor = .white
        view.tintColor = Constants.Color.secondPoint
        view.layer.cornerRadius = 10
        return view
    }()
    override func configureHierarchy() {
        uploadCommentView.addViews([commentTextView, commentButton])
        contentView.addViews([imageCollectionView, imageCounterLabel, likeButton, creatorView, detailsView, contentLabel, hashTagLabel, creatTimeLabel, commentsTableView, bottomHiddenView])
        scrollView.addSubview(contentView)
        addViews([scrollView, uploadCommentView, likeLottie, notInNetworkView])
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
        hashTagLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        creatTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(hashTagLabel.snp.bottom).offset(10)
            make.height.equalTo(20)
            make.leading.equalToSuperview().inset(10)
        }
        commentsTableView.snp.makeConstraints { make in
            make.top.equalTo(creatTimeLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(10)
            make.height.equalTo(1)
        }
        bottomHiddenView.snp.makeConstraints { make in
            make.top.equalTo(commentsTableView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(contentView)
            make.height.equalTo(70)
        }
        uploadCommentView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(self.keyboardLayoutGuide.snp.top).offset(-5)
            make.height.equalTo(50)
        }
        commentTextView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(10)
        }
        commentButton.snp.makeConstraints { make in
            make.leading.equalTo(commentTextView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
        }
        notInNetworkView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
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
