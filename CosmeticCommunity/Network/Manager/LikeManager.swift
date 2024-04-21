//
//  Like.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeManager {
    func changeLikeStatus(_ data: LikeQuery, postId: String) -> Observable<LikeModel> {
        return NetworkManager.shared.fetchAPI(type: LikeModel.self, router: Router.likeStatus(query: data, postId: postId))
    }

}
