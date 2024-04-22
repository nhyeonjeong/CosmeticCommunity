//
//  ProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import SnapKit

final class ProfileView: BaseView {

    let profileView = UserDataView(profileImageSize: .profile)
    let personalLable = {
        let view = UILabel()
        view.font = Constants.Font.large
        return view
    }()
    let buttonStack = {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 10
        return view
    }()
    let EditProfileButton = {
        let view = UIButton()
        view.setTitle("프로필 수정", for: .normal)
        view.setTitleColor(Constants.Color.text, for: .normal)
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.5 // 0이 완전투명
        view.layer.shadowRadius = 2 // 얼마나 퍼지는지
        view.layer.shadowOffset = .zero // CGSize(width: 0, height: 0) 와 동일
        view.layer.masksToBounds = false
        return view
    }()
    let logoutButton = {
        let view = UIButton()
        view.setTitle("로그아웃", for: .normal)
        view.setTitleColor(Constants.Color.text, for: .normal)
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.5 // 0이 완전투명
        view.layer.shadowRadius = 2 // 얼마나 퍼지는지
        view.layer.shadowOffset = .zero // CGSize(width: 0, height: 0) 와 동일
        view.layer.masksToBounds = false
        return view
    }()
    // segment
//    let segment = CustomSegmentedControl()
    // 페이지컨트롤러
    let postVC: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .lightGray
        return vc
    }()
    let followingVC: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .lightGray
        return vc
    }()
    let followersVC: UIViewController = {
        let vc = UIViewController()
        vc.view.backgroundColor = .lightGray
        return vc
    }()
    var dataViewControllers: [UIViewController] {
        [postVC, followingVC, followersVC]
    }
    lazy var pageViewContoller: UIPageViewController = {
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.setViewControllers([dataViewControllers[0]], direction: .forward, animated: true)
        return vc
    }()
    
    override func configureHierarchy() {
        buttonStack.addArrangedSubview(EditProfileButton)
        buttonStack.addArrangedSubview(logoutButton)
        addViews([profileView, personalLable, buttonStack/*, segment*/, pageViewContoller.view])
    }
    override func configureConstraints() {
        profileView.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide).inset(10)
        }

        personalLable.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(8)
            make.leading.equalTo(profileView.snp.leading)
            make.height.equalTo(30)
        }
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(personalLable.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(15)
            make.height.equalTo(40)
        }
        EditProfileButton.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
        logoutButton.snp.makeConstraints { make in
            make.verticalEdges.trailing.equalToSuperview()
        }
        pageViewContoller.view.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func upgradeView(_ data: UserModel) {
        print(data)
        profileView.upgradeView(profileImage: data.profileImage, nick: data.nick)
        personalLable.textColor = data.personalColor.textColor
        personalLable.text = data.personalColor.rawValue
        personalLable.backgroundColor = data.personalColor.backgroundColor

    }
}
