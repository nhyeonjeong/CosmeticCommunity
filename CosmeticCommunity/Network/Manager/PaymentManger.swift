//
//  PaymentManger.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/14.
//

import Foundation
import RxSwift
import RxCocoa

final class PaymentManger {
    func checkPaymentValid(query: PaymentQuery) -> Observable<Void> {
        print("🎁\(query)")
        return NetworkManager.shared.noResponseFetchAPI(router: Router.paymentValidation(query: query))
    }
}
