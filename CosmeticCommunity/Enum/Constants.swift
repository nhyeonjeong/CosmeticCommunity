//
//  Constant.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit

enum Constants {
    enum Color {
        static let point = UIColor.point
        static let secondPoint = UIColor.secondPoint
        static let text = UIColor.black
        static let subText = UIColor.lightGray
        static let gray6 = UIColor.systemGray6
    }
    enum Image {
        static let defulatProfileImage: UIImage = .defaultProfile
        static let defualtProfilePath = "uploads/posts/defaultprofileimage_1713676977790.jpeg"
        static let xButton = UIImage(systemName: "xmark.circle.fill")
        static let unclickedLike = UIImage(systemName: "hand.thumbsup")
        static let clickedLike = UIImage(systemName: "hand.thumbsup.fill")
        static let searchButton = UIImage(systemName: "magnifyingglass")
        static let recentSearchButton = UIImage(systemName: "arrow.up.left")
        static let category = UIImage(systemName: "line.horizontal.3")
        static let cursorClickImage = UIImage(systemName: "cursorarrow.rays")
        static let checkedItem = UIImage(systemName: "checkmark.circle")
        static let againNetwork = UIImage(systemName: "arrow.counterclockwise.circle.fill")
    }
    enum Font {
        static let bigTitle = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let large = UIFont.systemFont(ofSize: 17)
        static let boldTitle = UIFont.systemFont(ofSize: 17)
        static let normal = UIFont.systemFont(ofSize: 15)
        static let smallTitle = UIFont.boldSystemFont(ofSize: 13)
        static let small = UIFont.systemFont(ofSize: 13)
        static let verySmall = UIFont.systemFont(ofSize: 11)
    }
}

