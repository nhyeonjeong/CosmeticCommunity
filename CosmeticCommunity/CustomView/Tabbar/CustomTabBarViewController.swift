//
//  CustomTabBarViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class CustomTabBarViewController: UITabBarController {
    let disposeBag = DisposeBag()
    let tabBarMiddleButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 25,
                                                       weight: .bold,
                                                       scale: .large)
        button.setImage(UIImage(systemName: "plus.circle", withConfiguration: configuration),
                        for: .normal)
        
        // 버튼 색상
        button.tintColor = Constants.Color.point
        button.backgroundColor = .clear
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        self.tabBar.barTintColor = .white
        configureTabBarItems()
        setupTabbar(eachSide: 40, height: 50, y: 0)
    }

    func configureTabBarItems() {
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        homeViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 0)

        homeViewController.tabBarItem.imageInsets = UIEdgeInsets(top: -10, left: 0, bottom: 10, right: 0)
        
        let saveViewController = UINavigationController(rootViewController: SaveViewController())
        saveViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "folder"), tag: 0)
        saveViewController.tabBarItem.imageInsets = UIEdgeInsets(top: -10, left: 0, bottom: 10, right: 0)
        
        let fakeUploadViewController = UploadViewController()
        let uploadTabBarItem = UITabBarItem(title: nil, image: nil, tag: 1)
        uploadTabBarItem.isEnabled = false
        fakeUploadViewController.tabBarItem = uploadTabBarItem
        fakeUploadViewController.tabBarItem.imageInsets = UIEdgeInsets(top: -10, left: 0, bottom: 10, right: 0)
        
        viewControllers = [homeViewController, fakeUploadViewController, saveViewController]
        
        self.tabBar.addSubview(tabBarMiddleButton)
        tabBarMiddleButton.rx.tap.bind(with: self) { owner, _ in
            let uploadVC = UINavigationController(rootViewController: UploadViewController())
            uploadVC.modalPresentationStyle = .fullScreen
            owner.present(uploadVC, animated: true)
        }.disposed(by: disposeBag)
        
        tabBarMiddleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(40)
        }
    }
}
extension CustomTabBarViewController {
    func setupTabbar(eachSide space: CGFloat, height: CGFloat, y: CGFloat = 0) {
        let layer = CAShapeLayer()
        
        // tab bar layer 세팅
        let x: CGFloat = space
        let width: CGFloat = tabBar.bounds.width - (x*2)
        let height: CGFloat = height
        let centerImageY: CGFloat = 19 - (height/2)
        let y: CGFloat = centerImageY + y
        
        // 알약 모양으로 UIBezierPath 생성
        let frame: CGRect = CGRect(x: x, y: y, width: width, height: height)
        let path = UIBezierPath(roundedRect: frame,
                                cornerRadius: height/2).cgPath
        layer.path = path
        
        layer.fillColor = UIColor.white.cgColor
        layer.borderColor = UIColor.point.cgColor
        layer.borderWidth = 1
        
        // tab bar layer 그림자 설정
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.5
        
        self.tabBar.layer.insertSublayer(layer, at: 0)
        
        // tab bar items의 위치 설정
        self.tabBar.itemWidth = width / 5
        self.tabBar.itemPositioning = .centered
        
        // 틴트 컬러 설정
        self.tabBar.tintColor = Constants.Color.point
        self.tabBar.unselectedItemTintColor = Constants.Color.secondPoint
    }
}

