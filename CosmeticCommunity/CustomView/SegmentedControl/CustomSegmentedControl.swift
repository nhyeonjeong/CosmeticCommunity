//
//  CustomSegmentedControl.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/22.
//

import UIKit
import SnapKit

final class CustomSegmentedControl<T: SegmentCase>: UISegmentedControl {
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Color.point
        return view
      }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.removeElements()
        configureSegment()
        configureUnderLine()
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
//        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
//        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    private func configureSegment() {
        // 요소 넣기
        for segment in T.allCases {
            self.insertSegment(withTitle: segment.segmentTitle, at: segment.segmentIdx, animated: true)
        }
    }
    func configureUnderLine() {
        addSubview(underlineView)
        underlineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalToSuperview().dividedBy(self.numberOfSegments)
            make.height.equalTo(2)
        }
    }
    
}
