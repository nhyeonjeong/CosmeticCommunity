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
    let mainView = ProfileView()
    let viewModel = ProfileViewModel()
    
    override func loadView() {
        // 로그아웃된 상태라면 유저디폴트에 userId가 없다.
        let userId = UserDefaults.standard.string(forKey: "userId")
        guard let _ = userId else {
            view = NotloginView()
            return
        }
        // userid가 있는 상태라면
        view = mainView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // 엑세스토근 확인
        
    }
    override func bind() {
        
    }
    
}
