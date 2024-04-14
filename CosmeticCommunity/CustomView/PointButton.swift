//
//  PointButton.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import UIKit

final class PointButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Constants.Color.message
        self.setTitleColor(.white, for: .normal)
    }
    
    func configureTitle(_ title: String) {
        self.setTitle(title, for: .normal)
    }
    
    
    // 스토리보드로 할 때 실행되는 구문
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("no storyboard")
    }
}
