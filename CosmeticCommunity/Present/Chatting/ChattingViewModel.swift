//
//  ChattingViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/29.
//

import Foundation
import RxSwift
import RxCocoa

final class ChattingViewModel: InputOutput {
    let chattingManager = ChattingManager()
    var opponentId: String
    init(opponentId: String) {
        self.opponentId = opponentId
    }
    
    struct Input {
        let inputCheckChattingRoomExist: PublishSubject<Void>
        
    }
    struct Output {
        let outputChattingRoomExist: PublishSubject<Bool>
    }
    var disposeBag: RxSwift.DisposeBag = DisposeBag()
    
    var outputLoginView: RxRelay.PublishRelay<Void> = PublishRelay()
    
    func transform(input: Input) -> Output {
        let outputChattingRoomExist = PublishSubject<Bool>()
        
        input.inputCheckChattingRoomExist
            .flatMap {
                let query = ChattingRoomQuery(opponent_id: self.opponentId)
                return self.chattingManager.makeChattingRoomId(query: query)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputChattingRoomExist.onNext(false)
                            return Observable<ChattingRoomModel>.never()
                        }
//                        if error == APIError.notInNetwork {
//                            self.outputNotInNetworkTrigger.accept {
//                                input.inputUploadImagesTrigger.onNext(())
//                            }
//                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputCheckChattingRoomExist.onNext(())
                            } failureHandler: {
//                                outputUploadTrigger.onNext(nil)
                            } loginAgainHandler: {
                                self.outputLoginView.accept(())
                            }
                        }
                        outputChattingRoomExist.onNext(false)
                        return Observable<ChattingRoomModel>.never()
                    }
            }
            .subscribe(with: self) { owner, _ in
                outputChattingRoomExist.onNext(true)
            }.disposed(by: disposeBag)
            
        return Output(outputChattingRoomExist: outputChattingRoomExist)
    }
    
}
