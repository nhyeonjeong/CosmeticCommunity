//
//  NotLoginViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/15.
//

import UIKit

final class NotLoginViewController: BaseViewController {
    let mainView = NotLoginView()
    
    override func loadView() {
        view = mainView
    }
    deinit {
        print("NotLoginVC Deinit")
    }
    
    override func configureView() {
        mainView.loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
    }
    @objc func loginButtonClicked() {
        navigationController?.pushViewController(LoginViewController(), animated: true)
    }

}
