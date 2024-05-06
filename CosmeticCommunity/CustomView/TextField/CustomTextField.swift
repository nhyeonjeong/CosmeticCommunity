//
//  CustomTextField.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/04.
//

import UIKit
import SnapKit

final class CustomTextField: BaseView {
    var placeholder: String
    init(placeholder: String) {
        self.placeholder = placeholder
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let uiView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderColor = Constants.Color.secondPoint.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    let textField = UITextField()
    
    override func configureHierarchy() {
        addSubview(uiView)
        uiView.addSubview(textField)
    }
    override func configureConstraints() {
        uiView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(40)
        }
        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(10)
        }
    }
    override func configureView() {
        textField.placeholder = placeholder
    }
}
