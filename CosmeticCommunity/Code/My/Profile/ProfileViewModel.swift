//
//  ProfileViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/13.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel: InputOutput {
    let outputLoginView = PublishRelay<Void>()
    struct Input {
        
    }
    
    struct Output {
        
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
