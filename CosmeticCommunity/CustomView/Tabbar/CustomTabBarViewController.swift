//
//  CustomTabBarViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit

class CustomTabBarViewController: UITabBarController {

    let tabBarMiddleButton = {
        let button = UIButton()
        let configuation = UIImage.SymbolConfiguration(pointSize: 18,
                                                       weight: .heavy,
                                                       scale: .large)
        button.setImage(UIImage(systemName: "plus.diamond", withConfiguration: configuation),
                        for: .normal)
        
        // 버튼 색상
        button.tintColor = Constants.Color.point
        button.backgroundColor = .white
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
    }
    func configureView() {
        self.tabBar.addSubview(tabBarMiddleButton)
        tabBarMiddleButton.addTarget(self, action: #selector(middleButtonClicked), for: .touchUpInside)
        tabBarMiddleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.size.equalTo(40)
        }
    }
    // 업로드 화면으로 모달
    @objc func middleButtonClicked() {
        let uploadVC = UINavigationController(rootViewController: UploadViewController()) 
        uploadVC.modalPresentationStyle = .fullScreen
        present(uploadVC, animated: true)
    }
}
