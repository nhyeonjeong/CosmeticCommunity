//
//  InputOutput.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import Foundation
import RxSwift
import RxCocoa

protocol InputOutput: RxProtocol {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get }
    var outputLoginView: PublishRelay<Void> { get }
//    var outputNotInNetworkTrigger: PublishRelay<(() -> Void)?> { get }
    func transform(input: Input) -> Output
}
