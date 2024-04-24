//
//  OtherProfileView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import SnapKit

final class OtherProfileView: BaseView {
    let profileView = UserDataView(profileImageSize: .profile)
    let personalColor = {
        let view = UILabel()
        view.font = Constants.Font.large
        return view
    }()
    
    let followStackView = {
        let view = UIStackView()
//        view.spacing = 10
        view.distribution = .fillEqually
        view.axis = .horizontal
        return view
    }()
    let followersCountButton = {
        let view = CountButtonView()
        view.countLabel.text = "0"
        view.label.text = "팔로워"
        return view
    }()
    let followingCountButton = {
        let view = CountButtonView()
        view.countLabel.text = "0"
        view.label.text = "팔로잉"
        return view
    }()

    lazy var followButton = {
        
    }
    
}
