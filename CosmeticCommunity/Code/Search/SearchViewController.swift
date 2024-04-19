//
//  SearchViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {
    let mainView = SearchView()
    let viewModel = SearchViewModel()
    let disposeBar = DisposeBag()
    let data = ["dsfsdfsdfsdf", "wtwetwt", "34234"]
    override func loadView() {
        view = mainView
    }
    deinit {
        print("SearchVC Deinit")
    }
    override func bind() {
        let input = SearchViewModel.Input()
        BehaviorSubject<[String]>(value: data)
            .asDriver(onErrorJustReturn: [])
            .drive(mainView.collectionView.rx.items(cellIdentifier: SearchCollectionViewCell.identifier, cellType: SearchCollectionViewCell.self)) {(row, element, cell) in
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBar)
    }
    override func configureView() {
        setNavigationBar()
    }
    @objc func uploadButtonClikced() {
        navigationController?.pushViewController(UploadViewController(), animated: true)
    }
}

extension SearchViewController {
    func setNavigationBar() {
        navigationItem.title = "CoCo"
        let button = UIBarButtonItem(title: "글쓰기", style: .plain, target: self, action: #selector(uploadButtonClikced))
        
        navigationItem.rightBarButtonItem = button
    }
}
