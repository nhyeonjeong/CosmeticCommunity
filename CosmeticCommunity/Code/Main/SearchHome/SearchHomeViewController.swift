//
//  SearchViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchHomeViewController: BaseViewController {

    let mainView = SearchHomeView()
    let viewModel = SearchHomeViewModel()
    let inputPostsTrigger = PublishSubject<Void>()
    override func loadView() {
        view = mainView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputPostsTrigger.onNext(())
    }
    deinit {
        print("SearchHomeVC Deinit")
    }
    override func bind() {
        
        bindItemSelected()
        let input = SearchHomeViewModel.Input(inputFetchPostsTrigger: inputPostsTrigger)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView // 로그인화면으로 넘기는 로직연결
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

    }
    private func bindItemSelected() {
        mainView.resultCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, postData in
                let vc = PostDetailViewController()
                vc.postId = postData.post_id
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    override func configureView() {
        setNavigationBar()
    }
    @objc func searchButtonClicked() {
        navigationController?.pushViewController(SearchViewController(), animated: true)
    }
}

extension SearchHomeViewController {
    func setNavigationBar() {
        let button = UIBarButtonItem(image: Constants.Image.searchButton, style: .plain, target: self, action: #selector(searchButtonClicked))
        navigationItem.rightBarButtonItem = button
    }
}
