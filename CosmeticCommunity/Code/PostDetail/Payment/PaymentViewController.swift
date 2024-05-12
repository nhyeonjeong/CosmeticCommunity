//
//  PaymentViewController.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/12.
//

import UIKit
import SnapKit
import iamport_ios
import WebKit

final class PaymentViewController: BaseViewController {
    let payment = IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(APIKey.sesacKey)_\(Int(Date().timeIntervalSince1970))",
            amount: "100").then {
                $0.pay_method = PayMethod.card.rawValue // 결제할 수단
                $0.name = "잭님의 사투리 교실" // 결제할 상품명
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
                print(String(describing: iamportResponse))
            }
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
