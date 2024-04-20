//
//  BaseViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController, RxProtocol {
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
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
    
}
