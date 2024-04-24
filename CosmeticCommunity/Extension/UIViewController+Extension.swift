//
//  UIViewController+Extension.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/17.
//

import UIKit

extension UIViewController {
    func changeRootVC(vc: UIViewController, isNav: Bool = true) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        let nav = isNav ? UINavigationController(rootViewController: vc) : vc
        sceneDelegate?.window?.rootViewController = nav
        sceneDelegate?.window?.makeKeyAndVisible()
    }
    
    func alert(message: String, defaultTitle: String, yesAction: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        // 2. 버튼 생성
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let yes = UIAlertAction(title: defaultTitle, style: .default) { action in
            yesAction()
        }
        alert.addAction(cancel)
        alert.addAction(yes)
        present(alert, animated: true)
//        return alert
    }
}

extension UIViewController {
    // 네비게이션에 이미지버튼 만들기
    func configureProfileButton(_ button: UIButton) -> UIButton {
        let view = UIView()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalTo(view)
            make.size.equalTo(30)
        }
        return button
    }
}
