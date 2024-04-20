//
//  SearchViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {
    let mainView = HomeView()
    let viewModel = HomeViewModel()
    let disposeBar = DisposeBag()
    
    // 데이터 통신 트리거
    let inputPostsTrigger = PublishSubject<Void>()
    override func loadView() {
        view = mainView
    }
    deinit {
        print("HomeVC Deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputPostsTrigger.onNext(())
    }
    override func bind() {
        let input = HomeViewModel.Input(inputFetchPostsTrigger: inputPostsTrigger)
        
        let output = viewModel.transform(input: input)
 
        output.outputPostItems
            .flatMap { data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
                
            }
            .drive(mainView.collectionView.rx.items(cellIdentifier: HomeCollectionViewCell.identifier, cellType: HomeCollectionViewCell.self)) {(row, element, cell) in
                
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
    @objc func searchButtonClicked() {
        navigationController?.pushViewController(SearchViewController(), animated: true)
    }
}

extension HomeViewController {
    func setNavigationBar() {
        navigationItem.title = "CoCo"
        let uploadButton = UIBarButtonItem(title: "글쓰기", style: .plain, target: self, action: #selector(uploadButtonClikced))
        let searchButton = UIBarButtonItem(image: Constants.Image.searchButton                                         , style: .plain, target: self, action: #selector(searchButtonClicked))
        
        navigationItem.rightBarButtonItems = [uploadButton, searchButton]
    }
}
