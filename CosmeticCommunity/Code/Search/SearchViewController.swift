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
    override func loadView() {
        view = mainView
    }
    deinit {
        print("SearchVC Deinit")
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
        let button = UIBarButtonItem(title: "글쓰기", style: .plain, target: self, action: #selector(uploadButtonClikced))
        
        navigationItem.rightBarButtonItem = button
    }
}
