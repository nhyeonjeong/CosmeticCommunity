//
//  CustomSheetViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/25.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class CustomSheetViewController: BaseViewController {
    var postData: PostModel?
    
    var popPostDetailView: (() -> Void)?
    var popAfterEditPost: (() -> Void)?
    let viewModel = CustomSheetViewModel()
    let inputPostIdTrigger = PublishSubject<String?>()
    let inputEditButtonTrigger = PublishSubject<Void>()
    let inputDeleteButtonTrigger = PublishSubject<Void>()
    override func viewDidLoad() {
        super.viewDidLoad()
        // 탭 제스쳐
        let backViewTapped = UITapGestureRecognizer(target: self, action: #selector(backViewTapped))
        backView.addGestureRecognizer(backViewTapped)
        backView.isUserInteractionEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputPostIdTrigger.onNext(postData?.post_id)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    private let backView = {
        let view = UIView()
        view.backgroundColor = .darkGray.withAlphaComponent(0.7)
        return view
    }()
    private let buttonView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    lazy var editButton = {
        let view = UIButton()
        view.backgroundColor = .white
        view.setTitle("포스트 수정", for: .normal)
        view.setTitleColor(Constants.Color.point, for: .normal)
        view.addTarget(self, action: #selector(editButtonClicked), for: .touchUpInside)
        return view
    }()
    lazy var deleteButton = {
        let view = UIButton()
        view.backgroundColor = .white
        view.setTitle("포스트 삭제", for: .normal)
        view.setTitleColor(Constants.Color.point, for: .normal)
        view.addTarget(self, action: #selector(deleteButtonClicked), for: .touchUpInside)
        return view
    }()
    
    override func bind() {
        let input = CustomSheetViewModel.Input(inputPostId: inputPostIdTrigger, inputEditButtonTrigger: inputEditButtonTrigger, inputDeletebuttonTrigger: inputDeleteButtonTrigger)
        
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        
        output.outputDeleteButton
            .drive(with: self) { owner, value in
                if let value {
                    self.dismiss(animated: false)
                    self.popPostDetailView?()
                } else {
                    owner.view.makeToast("삭제에 실패했습니다", duration: 1.0, position: .center)
                }
            }
            .disposed(by: disposeBag)
    }
    
    @objc func deleteButtonClicked() {
        alert(message: "포스트를 삭제하시겠습니까?", defaultTitle: "삭제") {
            self.inputDeleteButtonTrigger.onNext(())
        }
    }
    @objc func editButtonClicked() {
        let vc = EditUploadViewController()
        vc.postData = postData
        vc.popAfterEditPost = {
            self.popAfterEditPost?()
            self.dismiss(animated: false) // pop한 뒤 dismiss까지 추가
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    override func configureHierarchy() {
        buttonView.addViews([editButton, deleteButton])
        view.addSubview(backView)
        view.addSubview(buttonView)
    }
    override func configureConstraints() {
        backView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        buttonView.snp.makeConstraints { make in
            make.top.equalTo(backView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(120)
        }
        editButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(editButton.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }
    }
    override func configureView() {
        self.view.backgroundColor = .clear
        backView.alpha = 0.0 // 처음에는 0으로 시작
    }
    
    @objc func backViewTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.backView.alpha = 0.0
            self.buttonView.frame = CGRect(x: 0, y: self.backView.bounds.height, width: self.backView.bounds.width, height: 120)
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func showBottomSheet() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.buttonView.frame = CGRect(x: 0, y: self.view.bounds.height - 120, width: self.view.bounds.width, height: 120)
            self.backView.alpha = 0.7
            self.view.layoutIfNeeded()
        }
    }

}
