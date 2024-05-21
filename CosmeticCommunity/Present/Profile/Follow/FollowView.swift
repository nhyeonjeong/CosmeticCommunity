//
//  FollowView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/22.
//

import UIKit

final class FollowView: BaseView {
    // rawtype을 가진 case들이라 enum은 타입을 가지지 못한다.
    enum FollowSegment: Int, SegmentCase {
        case followers = 0
        case following
        var segmentTitle: String {
            switch self {
            case .followers: return FollowType.followers.rawValue
            case .following: return FollowType.following.rawValue
            }
        }
        var segmentIdx: Int {
            switch self {
            case .followers: return 0
            case .following: return 1
            }
        }
    }
    // segment
    let segment = {
        let view = CustomSegmentedControl<FollowSegment>()
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
    // 세그먼트만 따로 업데이트
    func upgradeSegment(_ data: UserModel) {
        // 타이틀 바꾸기
        let followers = FollowSegment.followers
        let following = FollowSegment.following
        segment.setTitle("\(followers.segmentTitle) \(data.followers.count)", forSegmentAt: followers.segmentIdx)
        segment.setTitle("\(following.segmentTitle) \(data.following.count)", forSegmentAt: following.segmentIdx)
    }
}
