//
//  BaseViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self, #function) // self는 컨트롤러 인스턴스
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
