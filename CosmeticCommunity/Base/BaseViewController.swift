//
//  BaseViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController, RxProtocol {
    var outputLoginView = PublishRelay<Void>()
    
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setViewTapGesture(mainView: self.view)
        
        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
        bindLoginView()
    }
    func bind() {
        
    }
    // 보통 함수 내부는 비워두는 편
    func configureHierarchy() {
        
    }
    
    func configureConstraints() {
        
    }
    
    func configureView() {
        
    }
    
    func bindLoginView() {
        // 리프레시토큰 만료시 로그인 화면으로
        outputLoginView
            .asDriver(onErrorJustReturn: ())
            .drive(with: self) { owner, _ in
                let vc = UINavigationController(rootViewController: NotLoginViewController())
                vc.modalPresentationStyle = .fullScreen
                owner.navigationController?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
}
