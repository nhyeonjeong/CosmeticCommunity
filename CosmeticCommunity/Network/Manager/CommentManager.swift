//
//  CommentManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentManager {
    func changeLikeStatus(_ data: CommentQuery, postId: String) -> Observable<CommentModel> {
        return NetworkManager.shared.fetchAPI(type: CommentModel.self, router: Router.likeStatus(query: data, postId: postId))
    }
}