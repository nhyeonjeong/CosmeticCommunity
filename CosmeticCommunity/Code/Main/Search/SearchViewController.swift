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

    let mainView = SearchView()
    let viewModel = SearchViewModel()
    
    let inputCategorySelected = BehaviorSubject<PersonalColor>(value: .none)
    override func loadView() {
        view = mainView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    override func configureView() {
        setNavigationBar()
    }
    override func bind() {
        let input = SearchViewModel.Input(inputSearchText: mainView.textfield.rx.text, inputSearchEnterTrigger: mainView.textfield.rx.controlEvent(.editingDidEndOnExit), inputCategorySelected: inputCategorySelected)
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView

        output.outputPostItems
            .flatMap { data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
            }
            .drive(mainView.resultCollectionView.rx.items(cellIdentifier: HomeCollectionViewCell.identifier, cellType: HomeCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
        
        viewModel.categoryCases
            .bind(to: mainView.categoryCollectionView.rx.items(cellIdentifier: CategoryCollectionViewCell.identifier, cellType: CategoryCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
        
        mainView.categoryCollectionView.rx.modelSelected(PersonalColor.self)
            .bind(with: self) { owner, personal in
                print("🤬눌렀다")
                owner.inputCategorySelected.onNext(personal)
            }
            .disposed(by: disposeBag)
        
        mainView.resultCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, postData in
                let vc = PostDetailViewController()
                vc.postId = postData.post_id
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.outputNoResult
            .drive(with: self) { owner, value in
                print("😊\(value)")
                owner.mainView.noResultLabel.isHidden = value
            }
            .disposed(by: disposeBag)
    }
}

extension SearchViewController {
    func setNavigationBar() {
        navigationItem.titleView = mainView.textfield
        mainView.textfield.snp.makeConstraints { make in
            make.width.equalTo(300)
        }
        mainView.xButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(2)
        }
        
    }
}
