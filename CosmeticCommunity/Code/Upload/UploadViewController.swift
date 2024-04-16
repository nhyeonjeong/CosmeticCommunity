//
//  UploadViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit

class UploadViewController: BaseViewController {

    let mainView = UploadView()
    let viewModel = UploadViewModel()

    override func loadView() {
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 로그아웃된 상태라면 유저디폴트에 userId가 없다.
        let userId = UserDefaults.standard.string(forKey: "userId")
        // 로그아웃된 상태라면 로그인해달라는 화면
        guard let _ = userId else {
            let vc = UINavigationController(rootViewController: NotLoginViewController())
            vc.modalPresentationStyle = .fullScreen
            navigationController?.present(vc, animated: true)
            return
        }
    }
    override func bind() {
    
        
        
    }

}
