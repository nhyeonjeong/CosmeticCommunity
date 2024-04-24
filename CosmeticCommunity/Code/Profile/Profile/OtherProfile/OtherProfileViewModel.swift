//
//  OtherProfileViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/24.
//

import Foundation
import RxSwift
import RxCocoa

final class OtherProfileViewModel: InputOutput {
    
    var disposeBag = DisposeBag()
    var outputLoginView = PublishRelay<Void>()
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
