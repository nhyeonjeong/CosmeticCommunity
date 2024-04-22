//
//  CustomSegmentedControl.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/22.
//

import UIKit

final class CustomSegmentedControl: UISegmentedControl {
    private lazy var underlineView: UIView = {
        let width = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let height = 2.0
        let xPosition = CGFloat(self.selectedSegmentIndex * (width.isFinite == true ? Int(width) : 50))
        let yPosition = self.bounds.size.height - 1.0
        let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = .green
        self.addSubview(view)
        return view
      }()
      
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.removeElements()
    }
    override init(items: [Any]?) {
        super.init(items: items)
        self.removeElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func removeElements() {
        let image = UIImage()
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    override func layoutSubviews() {
      super.layoutSubviews()
      let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
      UIView.animate(
        withDuration: 0.1,
        animations: {
          self.underlineView.frame.origin.x = underlineFinalXPosition
        }
      )
    }
}
