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
    func uploadComment(_ item: CommentQuery, postId: String) -> Observable<CommentModel> {
        return NetworkManager.shared.fetchAPI(type: CommentModel.self, router: Router.uploadComment(query: item, postId: postId))
    }
    
    func deleteComment(postId: String, commentId: String) -> Observable<Void> {
        return NetworkManager.shared.noResponseFetchAPI(router: Router.deleteComment(postId: postId, commentId: commentId))
    }
}
