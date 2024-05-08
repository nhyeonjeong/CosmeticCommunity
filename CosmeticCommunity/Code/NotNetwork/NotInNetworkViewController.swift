//
//  NotInNetworkViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/07.
//

import UIKit
import RxSwift
import RxCocoa

final class NotInNetworkViewController: BaseViewController {
    let mainView = NotInNetworkView()
    override func loadView() {
        view = mainView
    }
}
