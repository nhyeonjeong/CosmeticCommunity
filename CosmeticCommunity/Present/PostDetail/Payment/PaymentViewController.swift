//
//  PaymentViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/12.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import WebKit
import iamport_ios
import Toast

final class PaymentViewController: BaseViewController {
    var postData: PostModel
    init(postData: PostModel) {
        self.postData = postData
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let viewModel = PaymentViewModel()
    let inputCheckValidTrigger = PublishSubject<(String, PostModel)>()
    lazy var payment = IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(APIKey.sesacKey)_\(Int(Date().timeIntervalSince1970))",
            amount: "6000").then {
                $0.pay_method = PayMethod.card.rawValue // 결제할 수단
                $0.name = postData.title // 결제할 상품명
                $0.buyer_name = "남현정" // 주문자 이름
                $0.app_scheme = "coco"
    }
    
    lazy var wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = UIColor.clear
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        Iamport.shared.paymentWebView(
            webViewMode: wkWebView,
            userCode: "imp57573124",
            payment: payment) { [weak self] iamportResponse in
                guard let self else { return }
                guard let response = iamportResponse else {
                    //
                    return
                }
                guard let isSuccess = response.success, let impId = response.imp_uid else {
                    // 옵셔널 체이닝 실패
                    return
                }
                if isSuccess {
                    self.inputCheckValidTrigger.onNext((impId, postData))
                } else {
                    // 결제에 실패했다면?
                }
            }
    }
    
    override func bind() {
        let input = PaymentViewModel.Input(inputCheckValidTrigger: inputCheckValidTrigger)
        let output = viewModel.transform(input: input)
        outputLoginView = output.outputLoginView
        output.outputPaySuccess
            .drive(with: self) { owner, _ in
                owner.view.makeToast("결제가 완료되었습니다", duration: 1.0, position: .top)
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
    }
    override func configureHierarchy() {
        view.addViews([wkWebView])
    }
    override func configureConstraints() {
        wkWebView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
