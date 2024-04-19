//
//  SearchViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit

final class SearchViewController: BaseViewController {

    let mainView = SearchView()
    
    override func loadView() {
        view = mainView
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    deinit {
        print("SearchVC Deinit")
    }

    override func configureView() {
        setNavigationBar()
    }
    
}

extension SearchViewController {
    func setNavigationBar() {
        let textfield = {
            let view = UITextField()
            view.placeholder = "검색어를 입력해주세요"
            return view
        }()
        navigationItem.titleView = textfield
        textfield.snp.makeConstraints { make in
            make.width.equalTo(300)
        }
        
    }
}
