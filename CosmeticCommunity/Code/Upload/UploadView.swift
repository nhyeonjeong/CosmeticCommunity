//
//  UploadView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import SnapKit

class UploadView: BaseView {

    let title = {
        let view = UITextField()
        view.placeholder = "제목"
        return view
    }()
    let content = {
        let view = UITextView()
        view.text = "내용"
        return view
    }()
    let personalColor = {
        let view = UILabel()
        view.text = "웜톤"
        return view
    }()
    let skinType = {
        let view = UILabel()
        view.text = "건성"
        return view
    }()
    
    override func configureHierarchy() {
        addViews([title, content])
    }
    
    override func configureConstraints() {
        title.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(30)
            make.centerX.equalToSuperview()
        }
        content.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.height.equalTo(100)
            make.horizontalEdges.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
    }
}

