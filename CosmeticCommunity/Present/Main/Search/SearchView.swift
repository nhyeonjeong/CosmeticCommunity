//
//  SearchView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/28.
//

import UIKit

final class SearchView: BaseView {
    let postType: PostType
    init(postType: PostType) {
        self.postType = postType
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let notInNetworkView = {
        let view = NotInNetworkView()
        view.isHidden = true
        return view
    }()
    let noResultLabel = {
        let view = UILabel()
        view.text = "검색 결과가 없습니다\n다시 검색해주세요"
        view.numberOfLines = 2
        view.isHidden = true
        view.textAlignment = .center
        view.configureLabel(textColor: Constants.Color.text, font: Constants.Font.large)
        return view
    }()
    let recentView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    let removeAllButton = {
        let view = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = "모두 삭제"
        config.baseBackgroundColor = .clear
        config.baseForegroundColor = Constants.Color.text
        config.buttonSize = .small
        view.configuration = config
        return view
    }()
    let recentSearchTableView = {
        let view = UITableView()
        view.register(RecentSearchTableViewCell.self, forCellReuseIdentifier: RecentSearchTableViewCell.identifier)
        view.rowHeight = 50
        return view
    }()
    let textFieldView = UIView()
    let textfield = {
        let view = UITextField()
        view.placeholder = "검색어를 입력해주세요"
        return view
    }()
    let xButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        view.tintColor = Constants.Color.subText
        return view
    }()
    let categoryStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
        
    }()
    let categoryTopView = UIView()
    let categoryTitleLabel = {
        let view = UILabel()
        view.text = "카테고리 |"
        view.textColor = Constants.Color.point
        return view
    }()
    lazy var categoryCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.categoryCollectionViewLayout())
        view.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        view.showsVerticalScrollIndicator = false
        return view
    }()
    lazy var resultCollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.resultCollectionViewLayout())
        view.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        return  view
    }()
    override func configureHierarchy() {
        textFieldView.addViews([textfield, xButton])
        categoryTopView.addViews([categoryTitleLabel, categoryCollectionView])
        categoryStackView.addArrangedSubview(categoryTopView)
        categoryStackView.addArrangedSubview(resultCollectionView)
        resultCollectionView.addSubview(noResultLabel)
        recentView.addViews([removeAllButton, recentSearchTableView])
        addViews([categoryStackView, recentView, notInNetworkView])
    }
    override func configureConstraints() {
        textfield.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            //            make.width.equalTo(330)
        }
        xButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
            make.leading.equalTo(textfield.snp.trailing).offset(8)
        }
        noResultLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        recentView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        removeAllButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(10)
        }
        recentSearchTableView.snp.makeConstraints { make in
            make.top.equalTo(removeAllButton.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        categoryTopView.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView)
            make.horizontalEdges.equalTo(categoryStackView).inset(10)
            make.height.equalTo(40)
        }
        categoryTitleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview()
        }
        categoryCollectionView.snp.makeConstraints { make in
            make.centerY.equalTo(categoryTitleLabel)
            make.leading.equalTo(categoryTitleLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        resultCollectionView.snp.makeConstraints { make in
            make.top.equalTo(categoryTopView.snp.bottom).offset(20)
            make.bottom.horizontalEdges.equalTo(categoryStackView)
        }
        notInNetworkView.snp.makeConstraints { make in
            make.top.equalTo(categoryCollectionView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    // 중고 search인지 아닌지에 따라서
    override func configureView() {
        switch postType {
        case .home:
            categoryTopView.isHidden = false
        case .usedItem:
            categoryTopView.isHidden = true
        }
    }
}
extension SearchView {
    func categoryCollectionViewLayout() -> UICollectionViewLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(10), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // Group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
        let group: NSCollectionLayoutGroup
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(15) // item간의 가로 간격
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        return UICollectionViewCompositionalLayout(section: section)
    }
    func resultCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let inset: CGFloat = 10
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width-inset*3) / 2 , height: 240) // 없으면 안됨
        layout.minimumLineSpacing = 10 // 세로간
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        layout.scrollDirection = .vertical // 스크롤 방향도 FlowLayout에 속한다 -> contentMode때문에 Fill로
        return layout
    }
}
