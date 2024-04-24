//
//  ProfileCustomButton.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit

final class ProfileCustomButton: UIButton {
    var title: String

    init(_ title: String) {
        self.title = title
        super.init(frame: .zero)
        configureView()
    }
    // 스토리보드로 할 때 실행되는 구문
    required init?(coder: NSCoder) {
        fatalError("no storyboard")
    }
    
    private func configureView() {
        setTitle(title, for: .normal)
        setTitleColor(Constants.Color.text, for: .normal)
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.5 // 0이 완전투명
        layer.shadowRadius = 2 // 얼마나 퍼지는지
        layer.shadowOffset = .zero // CGSize(width: 0, height: 0) 와 동일
        layer.masksToBounds = false
    }
}
