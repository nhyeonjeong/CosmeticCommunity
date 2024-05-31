//
//  ChattingView.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/29.
//

import UIKit
import SnapKit

final class ChattingView: BaseView {
    private let chattingTableView = UITableView()
    
    override func configureHierarchy() {
        addViews([chattingTableView])
    }
    override func configureConstraints() {
        chattingTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
