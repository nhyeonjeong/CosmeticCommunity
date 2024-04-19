//
//  Constant.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit

enum Constants {
    enum Color {
        static let point = UIColor.systemPink
        static let text = UIColor.black
//        enum classifyColor {
//            static let
//        }
        
    }
    
    enum Image {
        static let defualtProfilePath = "uploads/posts/defaultProfileImage_1713266372313.jpeg"
        static let xButton = UIImage(systemName: "xmark.circle.fill")
        static let unclickedLike = UIImage(systemName: "heart")
        static let clikcedLike = UIImage(systemName: "heart.fill")
    }
    enum Font {
        static let large = UIFont.systemFont(ofSize: 17)
        static let boldTitle = UIFont.systemFont(ofSize: 17)
        static let normal = UIFont.systemFont(ofSize: 15)
        static let small = UIFont.systemFont(ofSize: 13)
    }
}

