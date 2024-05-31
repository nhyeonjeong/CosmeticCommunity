//
//  OtherProfileViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class OtherProfileViewController: BaseViewController {
    var userId: String // 넘어온 유저의 userId
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let mainView = OtherProfileView()
    private let viewModel = OtherProfileViewModel()
    private lazy var inputFetchProfile = BehaviorSubject<String?>(value: userId)
    private let inputPrepatchTrigger = PublishSubject<[IndexPath]>()
    override func loadView() {
        view = mainView
    }
    deinit {
        print("OtherProfileVC Deinit")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.limit = "\(max(viewModel.postData.count, 20))"
        inputFetchProfile.onNext(userId)
    }
    override func bind() {
        bindChattingVieW()
        let input = OtherProfileViewModel.Input(inputFetchProfile: inputFetchProfile, inputPrepatchTrigger: inputPrepatchTrigger)
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        outputNotInNetworkTrigger = output.outputNotInNetworkTrigger
        output.outputProfileResult
            .drive(with: self) { owner, data in
                if let data {
                    owner.mainView.upgradeUserView(data) // 상단 뷰 다시 그리기
                    owner.navigationItem.title = data.nick
                } else {
                    owner.view.makeToast("통신에 실패했습니다", duration: 1.0, position: .top)
                }
            }
            .disposed(by: disposeBag)
    
        output.outputPostItems
            .flatMap({ data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
                
            })
            .drive(mainView.postsCollectionView.rx.items(cellIdentifier: PostImageCollectionViewCell.identifier, cellType: PostImageCollectionViewCell.self)) { (row, element, cell) in
                cell.upgradeCell(element.files.first)
                print("\(element)")
            }
            .disposed(by: disposeBag)

        mainView.postsCollectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, data in
                let vc = PostDetailViewController(postId: data.post_id)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        // prefetch
        mainView.postsCollectionView.rx.prefetchItems
            .bind(with: self) { owner, indexPaths in
                owner.inputPrepatchTrigger.onNext(indexPaths)
            }
            .disposed(by: disposeBag)
        
        output.outputNoResult
            .drive(with: self) { owner, value in
                owner.mainView.noResultLabel.isHidden = value
            }
            .disposed(by: disposeBag)
        
        // MARK: - Network
        // 새로고침 버튼 tap
        mainView.notInNetworkView.restartButton.rx.tap
            .withLatestFrom(viewModel.outputNotInNetworkTrigger)
            .debug()
            .bind(with: self) { owner, againFunc in
                againFunc?()
            }.disposed(by: disposeBag)
        
        outputNotInNetworkTrigger
            .asDriver(onErrorJustReturn: {})
            .drive(with: self) { owner, value in
                if let _ = value {
                    owner.mainView.notInNetworkView.isHidden = false
                } else {
                    owner.mainView.notInNetworkView.isHidden = true // 네트워크 연결되었음
                }
            }.disposed(by: disposeBag)
    }
}
extension OtherProfileViewController {
    func bindChattingVieW() {
        mainView.chattingButton.rx.tap
            .bind(with: self) { owner, _ in
                // 상대방의 userId넘기기
                owner.navigationController?.pushViewController(ChattingViewController(opponentId: owner.userId), animated: true)
            }.disposed(by: disposeBag)
    }
}
