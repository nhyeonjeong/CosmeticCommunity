//
//  SearchViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/28.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    let postType: PostType
    let viewModel: SearchViewModel
    let mainView: SearchView
    init(postType: PostType) {
        self.postType = postType
        self.viewModel = SearchViewModel(posttype: postType)
        self.mainView = SearchView(postType: postType)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let inputCategorySelected = BehaviorSubject<PersonalColor>(value: .spring)
    let inputRecentSearchTable = BehaviorSubject<[String]?>(value: UserDefaultManager.shared.getRecentSearch())
    let inputPrepatchTrigger = PublishSubject<[IndexPath]>()
    override func loadView() {
        view = mainView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputRecentSearchTable.onNext(UserDefaultManager.shared.getRecentSearch())
        // 포스트로 갔다가 뒤로 돌아올 때 이전에 패치했던 부분까지 다시 패치
        viewModel.limit = "\(max(viewModel.postData.count, 20))"
        inputCategorySelected.onNext(viewModel.selectedCategory)
        
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    override func configureView() {
        setNavigationBar()
    }
    override func bind() {
        let input = SearchViewModel.Input(inputSearchText: mainView.textfield.rx.text, inputSearchEnterTrigger: mainView.textfield.rx.controlEvent(.editingDidEndOnExit), inputRemoveRecent: mainView.removeAllButton.rx.tap, inputCategorySelected: inputCategorySelected, inputRecentSearchTable: inputRecentSearchTable, inputPrepatchTrigger: inputPrepatchTrigger)
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        outputNotInNetworkTrigger = output.outputNotInNetworkTrigger
        output.outputPostItems
            .flatMap { data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
            }
            .drive(mainView.resultCollectionView.rx.items(cellIdentifier: PostCollectionViewCell.identifier, cellType: PostCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
        
        output.outputHideRecentSearch
            .drive(with: self) { owner, value in
                owner.mainView.recentView.isHidden = value
            }
            .disposed(by: disposeBag)
        
        output.outputMessage
            .drive(with: self) { owner, message in
                owner.view.makeToast(message, duration: 1.0, position: .top)
            }
            .disposed(by: disposeBag)
        
        output.outputRecentSearchTable
            .asDriver(onErrorJustReturn: [])
            .drive(mainView.recentSearchTableView.rx.items(cellIdentifier: RecentSearchTableViewCell.identifier, cellType: RecentSearchTableViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
                cell.arrowButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.mainView.textfield.text = element
                        UserDefaultManager.shared.saveRecentSearch(element)
                        let list = UserDefaultManager.shared.getRecentSearch() ?? []
                        print(list)
                        output.outputRecentSearchTable.accept(list)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        viewModel.categoryCases
            .bind(to: mainView.categoryCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.identifier, cellType: CategoryCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element, isSelected: self.viewModel.selectedCategory == element)
            }
            .disposed(by: disposeBag)
        // 카테고리 눌렸을 때
        mainView.categoryCollectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.inputCategorySelected.onNext(PersonalColor.personalCases[indexPath.row])
            }
            .disposed(by: disposeBag)
        
        // textfield를 선택하면 최근검색어 다시 나오도록
        mainView.textfield.rx.controlEvent(.editingDidBegin)
            .bind(with: self) { owner, _ in
                owner.mainView.recentView.isHidden = false
                // 다시 최근검색어 가져와서 보여주기
                owner.inputRecentSearchTable.onNext(UserDefaultManager.shared.getRecentSearch())
            }
            .disposed(by: disposeBag)
        
        mainView.xButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.mainView.textfield.text = ""
            }
            .disposed(by: disposeBag)
        mainView.resultCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, postData in
                let vc = PostDetailViewController(postId: postData.post_id)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.outputNoResult
            .drive(with: self) { owner, value in
                owner.mainView.noResultLabel.isHidden = value
            }
            .disposed(by: disposeBag)
        
        // prefetch
        mainView.resultCollectionView.rx.prefetchItems
            .bind(with: self) { owner, indexPaths in
                print(indexPaths)
                owner.inputPrepatchTrigger.onNext(indexPaths)
            }
            .disposed(by: disposeBag)
        
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
    }
}

extension SearchViewController {
    func setNavigationBar() {
        navigationItem.titleView = mainView.textFieldView
        navigationItem.titleView?.snp.makeConstraints({ make in
            make.width.equalTo(300)
        })
    }
}
