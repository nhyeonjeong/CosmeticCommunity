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
    
    func alert(message: String, yesAction: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        // 2. 버튼 생성
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let yes = UIAlertAction(title: "업로드", style: .default) { action in
            print("upload")
            yesAction()
        }
        alert.addAction(cancel)
        alert.addAction(yes)
        present(alert, animated: true)
//        return alert
    }
}