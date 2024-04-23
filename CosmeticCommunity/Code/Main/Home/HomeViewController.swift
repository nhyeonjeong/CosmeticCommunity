//
//  SearchViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/16.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class HomeViewController: BaseViewController {
    // NavigationBarButton커스텀버튼(프로필 이미지 패치)
    let button = {
        let view = UIButton()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    let mainView = HomeView()
    let viewModel = HomeViewModel()
    // viewModel에 전달할 트리거
    let inputProfileImageTrigger = PublishSubject<Void>()
    let inputPostsTrigger = PublishSubject<Void>()
    override func loadView() {
        view = mainView
    }
    deinit {
        print("HomeVC Deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputProfileImageTrigger.onNext(())
        inputPostsTrigger.onNext(())
    }
    override func bind() {
        
        bindItemSelected()
        let input = HomeViewModel.Input(inputProfileImageTrigger: inputProfileImageTrigger, inputFetchPostsTrigger: inputPostsTrigger)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        output.outputPostItems
            .flatMap { data -> Driver<[PostModel]> in
                guard let posts = data else {
                    return Driver.never()
                }
                return BehaviorRelay(value: posts).asDriver()
                
            }
            .drive(mainView.collectionView.rx.items(cellIdentifier: HomeCollectionViewCell.identifier, cellType: HomeCollectionViewCell.self)) {(row, element, cell) in
                
                cell.upgradeCell(element)
            }
            .disposed(by: disposeBag)
        // 상단 프로필버튼 이미지 가져오기
        output.outputProfileImageTrigger
            .drive(with: self) { owner, path in
                KingfisherManager.shared.getImageData(path: path) { KFImage in
                    print("vc에서 업데이트! \(KFImage)")
                    DispatchQueue.main.async {
                        owner.button.setImage(KFImage, for: .normal)
                    }
                }
            }
            .disposed(by: disposeBag)

    }
    
    private func bindItemSelected() {
        mainView.collectionView.rx.modelSelected(PostModel.self)
            .bind(with: self) { owner, postData in
                let vc = PostDetailViewController()
                vc.postId = postData.post_id
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureView() {
        setNavigationBar()
    }
    @objc func profileButtonClicked() {
        navigationController?.pushViewController(MyProfileViewController(), animated: true)
    }
    @objc func searchButtonClicked() {
        navigationController?.pushViewController(SearchViewController(), animated: true)
    }
}

extension HomeViewController {
    func setNavigationBar() {
        navigationItem.title = "CoCo"
        let customView = configureProfileButton()
        customView.addTarget(self, action: #selector(profileButtonClicked), for: .touchUpInside)
        
        let profileButton = UIBarButtonItem(customView: customView)
        
        let searchButton = UIBarButtonItem(image: Constants.Image.searchButton                                         , style: .plain, target: self, action: #selector(searchButtonClicked))
        
        navigationItem.rightBarButtonItems = [profileButton, searchButton]
    }
    
    func configureProfileButton() -> UIButton {
        let view = UIView()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalTo(view)
            make.size.equalTo(30)
        }
//        button.backgroundColor = .red
        return button
    }
}
