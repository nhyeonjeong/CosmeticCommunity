//
//  ProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit
import SnapKit

final class ProfileView: BaseView {
    // rawtype을 가진 case들이라 enum은 타입을 가지지 못한다.
    enum ProfileSegmentCase: Int, SegmentCase {
        case posts = 0
        case followers
        case following
        var segmentTitle: String {
            switch self {
            case .posts: return "게시글"
            case .followers: return "팔로워"
            case .following: return "팔로잉"
            }
        }
        var segmentIdx: Int {
            switch self {
            case .posts: return 0
            case .followers: return 1
            case .following: return 2
            }
        }
    }
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
    let segment = {
        let view = CustomSegmentedControl<ProfileSegmentCase>()
        view.selectedSegmentIndex = 0
        return view
    }()

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
        addViews([profileView, personalLable, buttonStack, segment, pageViewContoller.view])
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
        segment.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(30)
        }
        pageViewContoller.view.snp.makeConstraints { make in
            make.top.equalTo(segment.snp.bottom).offset(10)
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
    // 세그먼트만 따로 업데이트
    func upgradeSegment(_ data: UserModel) {
        // 타이틀 바꾸기
        let postTitle = "\(ProfileSegmentCase.posts.segmentTitle) \(data.posts.count)"
        let followersCount = "\(ProfileSegmentCase.followers.segmentTitle) \(data.followers.count)"
        let followingCount = "\(ProfileSegmentCase.following.segmentTitle) \(data.following.count)"
    }
}
