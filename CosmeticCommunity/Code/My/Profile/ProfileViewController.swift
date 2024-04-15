//
//  ProfileViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileViewController: BaseViewController {
    private let mainView = ProfileView()
    private let viewModel = ProfileViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    deinit {
        print("ProfileVC Deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // 엑세스토근 확인
        
    }
    override func bind() {
        // 로그아웃된 상태라면 유저디폴트에 userId가 없다.
        let userId = UserDefaults.standard.string(forKey: "userId")
        // 로그아웃된 상태라면 로그인해달라는 화면
        guard let _ = userId else {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = scene?.delegate as? SceneDelegate
            
            let vc = NotLoginViewController()
            let nav = UINavigationController(rootViewController: vc)

            sceneDelegate?.window?.rootViewController = nav
            sceneDelegate?.window?.makeKeyAndVisible()
            return
        }
        
    }
    
}
