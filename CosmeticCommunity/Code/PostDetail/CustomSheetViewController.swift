//
//  CustomSheetViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/25.
//

import UIKit

final class CustomSheetViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 탭 제스쳐
        let backViewTapped = UITapGestureRecognizer(target: self, action: #selector(backViewTapped))
        backView.addGestureRecognizer(backViewTapped)
        backView.isUserInteractionEnabled = true
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
    let editButton = {
        let view = UIButton()
        view.backgroundColor = .white
        view.setTitle("포스트 수정", for: .normal)
        view.setTitleColor(Constants.Color.point, for: .normal)
        return view
    }()
    let deleteButton = {
        let view = UIButton()
        view.backgroundColor = .white
        view.setTitle("포스트 삭제", for: .normal)
        view.setTitleColor(Constants.Color.point, for: .normal)
        return view
    }()
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
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
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
