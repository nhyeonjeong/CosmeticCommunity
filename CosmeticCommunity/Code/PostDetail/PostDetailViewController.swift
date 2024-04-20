//
//  PostDetailViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit
import RxSwift
import RxCocoa

final class PostDetailViewController: BaseViewController {
    var postData: PostModel? // 받아온 post정보
    
    let mainView = PostDetailView()
    let viewModel = PostDetailViewModel()
    override func loadView() {
        view = mainView
    }
    deinit {
        print("PostDetailVC Deinit")
    }
    
    override func bind() {
        
    }

}
