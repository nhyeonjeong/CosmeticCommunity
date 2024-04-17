//
//  UIView+Extension.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import UIKit

extension UIView {
    static var identifier: String {
        String(describing: self)
    }
    
    func addViews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
}

