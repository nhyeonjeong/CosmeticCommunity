//
//  GradientView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/05.
//

import QuartzCore
import UIKit

final class GradientView: BaseView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setGradient()
    }
    var gradientLayer: CAGradientLayer {
        guard let gradientLayer = self.layer as? CAGradientLayer else {
            return CAGradientLayer()
        }
        return gradientLayer
    }
    func setGradient() {
        guard let gradientLayer = self.layer as? CAGradientLayer else {
            return
        }
        // 그라데이션 색상 설정
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        // 그라데이션 방향 설정 (위에서 아래로)
        gradientLayer.startPoint = CGPoint(x: 0.8, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 1)
    }
    // 스토리보드로 할 때 실행되는 구문
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("no storyboard")
    }
}
