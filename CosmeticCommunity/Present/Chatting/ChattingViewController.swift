//
//  ChattingViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/29.
//

import UIKit
import RxSwift
import RxCocoa

final class ChattingViewController: BaseViewController {
    var opponentId: String
    var viewModel: ChattingViewModel
    init(opponentId: String) {
        self.opponentId = opponentId
        self.viewModel = ChattingViewModel(opponentId: opponentId)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented   ")
    }
    let inputCheckChattingRoomExist = PublishSubject<Void>()
    let mainView = ChattingView()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputCheckChattingRoomExist.onNext(())
    }
    override func bind() {
        let input = ChattingViewModel.Input(inputCheckChattingRoomExist: inputCheckChattingRoomExist)
        
        let output = viewModel.transform(input: input)
        output.outputChattingRoomExist
            .bind(with: self) { owner, value in
                print("👾", value)
            }.disposed(by: disposeBag)
    }
}

