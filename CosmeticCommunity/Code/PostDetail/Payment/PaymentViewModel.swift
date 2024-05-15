//
//  PaymentViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/14.
//

import Foundation
import RxSwift
import RxCocoa
import iamport_ios

final class PaymentViewModel: InputOutput {
    let paymentManager = PaymentManger()
    let disposeBag: DisposeBag = DisposeBag()
    let outputLoginView: PublishRelay<Void> = PublishRelay()
    struct Input {
        let inputCheckValidTrigger: PublishSubject<(String, PostModel)> // imp_id, post_id
    }
    
    struct Output {
        let outputLoginView: PublishRelay<Void>
        let outputPaySuccess: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let outputPaySuccess = PublishRelay<Void>()
        input.inputCheckValidTrigger
            .flatMap { impId, postData in
                let query = PaymentQuery(impId: impId, postId: postData.post_id, productName: postData.title, price: 100)
                print(query)
                return self.paymentManager.checkPaymentValid(query: query)
                    .catch { error in
                        guard let error = error as? APIError else {
//                            outputPostItems.accept(nil)
                            return Observable<Void>.never()
                        }
//                        if error == APIError.notInNetwork {
//                            self.outputNotInNetworkTrigger.accept {
//                                searchTrigger.onNext((hashTag, category))
//                            }
//                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputCheckValidTrigger.onNext((impId, postData))
                            } failureHandler: {
//                                outputPostItems.accept(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        print(error.errorMessage)
                        return Observable<Void>.never()
                    }
            }
            .subscribe(with: self) { owner, _ in
                // 결제검증 완료
                outputPaySuccess.accept(())
            }.disposed(by: disposeBag)
        return Output(outputLoginView: outputLoginView, outputPaySuccess: outputPaySuccess.asDriver(onErrorJustReturn: ()))
    }
}
